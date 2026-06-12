import Foundation
import DeviceCheck
import CryptoKit
import OSLog

actor AttestService {
    static let shared = AttestService()
    
    private let service = DCAppAttestService.shared
    private let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "AppAttest")
    private let keychain = AppAttestKeychain()
    private let challengeEndpoint = "https://api.bisquit.host/auth/challenge"
    
    private var cachedKeyID: String?
    
    var isSupported: Bool {
        service.isSupported
    }
    
    func attestDevice(userID: String? = nil) async throws -> AttestResult {
        logger.info("Starting attestation flow for userID: \(userID ?? "nil")")
        
        guard service.isSupported else {
            logger.error("App Attest not supported on this device")
            throw AttestError.notSupported
        }
        
        // 1. Get challenge from server
        logger.info("Step 1/4: Fetching challenge...")
        let challenge: Data
        
        do {
            challenge = try await fetchChallenge(userID: userID, purpose: .attestation)
        } catch let error as AppAttestChallengeError {
            switch error {
            case .invalidResponse:
                throw AttestError.invalidResponse
                
            case .serverError(let message):
                throw AttestError.serverError(message)
            }
        } catch {
            throw AttestError.serverError("\(error)")
        }
        
        logger.info("Step 1/4: Challenge received (\(challenge.count) bytes)")
        
        // 2. Load or generate key
        logger.info("Step 2/4: Loading App Attest key...")
        var keyID = try await currentKeyID()
        logger.info("Step 2/4: App Attest key ready")
        
        // 3. Hash the challenge for attestation
        logger.info("Step 3/4: Hashing challenge...")
        let challengeHash = Data(SHA256.hash(data: challenge))
        logger.debug("Challenge hash: \(challengeHash.base64EncodedString())")
        
        // 4. Attest the key with Apple
        logger.info("Step 4/4: Attesting with Apple...")
        let attestation: Data
        
        do {
            attestation = try await attestKey(keyID: keyID, clientDataHash: challengeHash)
        } catch {
            guard shouldRegenerateKey(after: error) else {
                throw error
            }
            
            logger.info("Stored App Attest key is invalid, generating replacement")
            try clearStoredKeyID()
            keyID = try await generateAndStoreKey()
            attestation = try await attestKey(keyID: keyID, clientDataHash: challengeHash)
        }
        
        logger.info("Step 4/4: Apple attestation received")
        
        let result = AttestResult(
            challenge: challenge.base64EncodedString(),
            attestation: attestation.base64EncodedString(),
            keyID: keyID
        )
        
        logger.info("Attestation complete - ready to send with login request")
        
        return result
    }

    func assertion(userID: String? = nil, action: String, payload: Data) async throws -> AttestAssertionResult {
        guard try storedKeyID() != nil else {
            throw AttestError.missingKey
        }
        
        let challenge = try await fetchChallenge(userID: userID, purpose: .assertion)
        
        return try await assertion(challenge: challenge, action: action, payload: payload)
    }
    
    private func assertion(challenge: Data, action: String, payload: Data) async throws -> AttestAssertionResult {
        let clientData = try JSONEncoder().encode(
            AttestAssertionClientData(
                challenge: challenge.base64EncodedString(),
                action: action,
                payloadHash: Data(SHA256.hash(data: payload)).base64EncodedString()
            )
        )
        
        return try await assertion(challenge: challenge, clientData: clientData)
    }
    
    private func assertion(challenge: Data, clientData: Data) async throws -> AttestAssertionResult {
        logger.info("Starting assertion flow")
        
        guard service.isSupported else {
            logger.error("App Attest not supported on this device")
            throw AttestError.notSupported
        }
        
        guard let keyID = try storedKeyID() else {
            throw AttestError.missingKey
        }
        
        let clientDataHash = Data(SHA256.hash(data: clientData))
        let assertion = try await generateAssertion(keyID: keyID, clientDataHash: clientDataHash)
        
        return AttestAssertionResult(
            challenge: challenge.base64EncodedString(),
            assertion: assertion.base64EncodedString(),
            keyID: keyID,
            clientData: clientData.base64EncodedString()
        )
    }
    
    // MARK: - Private Methods
    
    private func fetchChallenge(userID: String?, purpose: AppAttestChallengePurpose) async throws -> Data {
        guard let url = URL(string: challengeEndpoint) else {
            throw AppAttestChallengeError.invalidResponse
        }
        
        struct ChallengeRequest: Encodable {
            let userID: String?
            let purpose: AppAttestChallengePurpose
        }
        
        struct ChallengeResponse: Decodable {
            let challenge: String
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            ChallengeRequest(
                userID: userID,
                purpose: purpose
            )
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppAttestChallengeError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AppAttestChallengeError.serverError(message)
        }
        
        let decoded = try JSONDecoder().decode(ChallengeResponse.self, from: data)
        
        guard let challengeData = Data(base64Encoded: decoded.challenge) else {
            throw AppAttestChallengeError.invalidResponse
        }
        
        return challengeData
    }
    
    private func generateKey() async throws -> String {
        logger.debug("Generating App Attest key...")
        
        return try await withCheckedThrowingContinuation { continuation in
            service.generateKey { [logger] keyID, error in
                if let error {
                    logger.error("Key generation failed: \(error)")
                    continuation.resume(throwing: AttestError.keyGenerationFailed(error))
                    
                } else if let keyID {
                    logger.debug("Key generated: \(keyID)")
                    continuation.resume(returning: keyID)
                    
                } else {
                    logger.error("Key generation returned nil")
                    continuation.resume(throwing: AttestError.invalidResponse)
                }
            }
        }
    }
    
    private func currentKeyID() async throws -> String {
        if let cachedKeyID {
            return cachedKeyID
        }
        
        if let keyID = try keychain.loadKeyID() {
            cachedKeyID = keyID
            return keyID
        }
        
        return try await generateAndStoreKey()
    }
    
    private func storedKeyID() throws -> String? {
        if let cachedKeyID {
            return cachedKeyID
        }
        
        guard let keyID = try keychain.loadKeyID() else {
            return nil
        }
        
        cachedKeyID = keyID
        return keyID
    }
    
    private func generateAndStoreKey() async throws -> String {
        let keyID = try await generateKey()
        try keychain.saveKeyID(keyID)
        cachedKeyID = keyID
        
        return keyID
    }
    
    private func clearStoredKeyID() throws {
        cachedKeyID = nil
        try keychain.deleteKeyID()
    }
    
    private func attestKey(keyID: String, clientDataHash: Data) async throws -> Data {
        logger.debug("Attesting key with Apple - keyID: \(keyID)")
        logger.debug("Client data hash: \(clientDataHash.base64EncodedString())")
        
        return try await withCheckedThrowingContinuation { continuation in
            service.attestKey(keyID, clientDataHash: clientDataHash) { [logger] attestation, error in
                if let error {
                    logger.error("Apple attestation failed: \(error)")
                    continuation.resume(throwing: AttestError.attestationFailed(error))
                    
                } else if let attestation {
                    logger.debug("Apple attestation received, size: \(attestation.count) bytes")
                    continuation.resume(returning: attestation)
                    
                } else {
                    logger.error("Apple attestation returned nil")
                    continuation.resume(throwing: AttestError.invalidResponse)
                }
            }
        }
    }
    
    private func generateAssertion(keyID: String, clientDataHash: Data) async throws -> Data {
        logger.debug("Generating assertion with keyID: \(keyID)")
        
        return try await withCheckedThrowingContinuation { continuation in
            service.generateAssertion(keyID, clientDataHash: clientDataHash) { [logger] assertion, error in
                if let error {
                    logger.error("Assertion generation failed: \(error)")
                    continuation.resume(throwing: AttestError.assertionFailed(error))
                    
                } else if let assertion {
                    continuation.resume(returning: assertion)
                    
                } else {
                    logger.error("Assertion generation returned nil")
                    continuation.resume(throwing: AttestError.invalidResponse)
                }
            }
        }
    }
    
    private func shouldRegenerateKey(after error: Error) -> Bool {
        guard case AttestError.attestationFailed(let underlying) = error else {
            return false
        }
        
        guard let dcError = underlying as? DCError else {
            return false
        }
        
        return dcError.code == .invalidKey
    }
}
