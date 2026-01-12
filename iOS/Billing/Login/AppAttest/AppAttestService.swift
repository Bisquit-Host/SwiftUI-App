import Foundation
import DeviceCheck
import CryptoKit
import OSLog

enum AppAttestError: LocalizedError {
    case notSupported,
         serverError(String),
         invalidResponse,
         keyGenerationFailed(Error),
         attestationFailed(Error),
         assertionFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            "App Attest is not supported on this device"
            
        case .serverError(let message):
            message
            
        case .invalidResponse:
            "Invalid server response"
            
        case .keyGenerationFailed(let error):
            "Key generation failed: \(error.localizedDescription)"
            
        case .attestationFailed(let error):
            "Attestation failed: \(error.localizedDescription)"
            
        case .assertionFailed(let error):
            "Assertion failed: \(error.localizedDescription)"
        }
    }
}

struct AttestationResult {
    let userID: String?
    let publicKey: String
    let keyID: String
}

struct AssertionResult {
    let userID: String?
    let counter: Int
}

actor AppAttestService {
    static let shared = AppAttestService()
    
    private let baseURL = URL(string: "https://attester.topscrech.dev")!
    private let service = DCAppAttestService.shared
    private let logger = Logger(subsystem: "dev.topscrech.bisquit", category: "AppAttest")
    
    private var storedKeyID: String?
    private var storedPublicKey: String?
    
    var isSupported: Bool {
        service.isSupported
    }
    
    func attestDevice(userID: String? = nil) async throws -> AttestationResult {
        guard service.isSupported else {
            throw AppAttestError.notSupported
        }
        
        // 1. Get challenge from server
        let challenge = try await fetchChallenge(userID: userID)
        logger.info("Received challenge from server")
        
        // 2. Generate key
        let keyID = try await generateKey()
        logger.info("Generated App Attest key")
        
        // 3. Hash the challenge for attestation
        let challengeHash = Data(SHA256.hash(data: challenge))
        
        // 4. Attest the key with Apple
        let attestation = try await attestKey(keyID: keyID, clientDataHash: challengeHash)
        logger.info("Key attested by Apple")
        
        // 5. Verify attestation with our server
        let result = try await verifyAttestation(
            challenge: challenge,
            attestation: attestation,
            keyID: keyID
        )
        
        logger.info("Attestation verified by server for user: \(result.userID ?? "anonymous")")
        
        // Store for later assertions
        storedKeyID = keyID
        storedPublicKey = result.publicKey
        
        return result
    }
    
    func assertRequest(userID: String? = nil, clientData: Data) async throws -> AssertionResult {
        guard service.isSupported else {
            throw AppAttestError.notSupported
        }
        
        guard let keyID = storedKeyID, let publicKey = storedPublicKey else {
            throw AppAttestError.serverError("Device not attested. Call attestDevice first")
        }
        
        // 1. Get challenge from server
        let challenge = try await fetchChallenge(userID: userID)
        
        // 2. Create client data hash (challenge + actual client data)
        var dataToSign = challenge
        dataToSign.append(clientData)
        let clientDataHash = Data(SHA256.hash(data: dataToSign))
        
        // 3. Generate assertion
        let assertion = try await generateAssertion(keyID: keyID, clientDataHash: clientDataHash)
        
        // 4. Verify with server
        let result = try await verifyAssertion(
            challenge: challenge,
            assertion: assertion,
            publicKey: publicKey,
            clientData: clientData
        )
        
        return result
    }
    
    // MARK: - Private Methods
    
    private func fetchChallenge(userID: String?) async throws -> Data {
        let url = await URL(string: Endpoint.attestChallenge)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        struct ChallengeRequest: Encodable {
            let userID: String?
        }
        
        request.httpBody = try JSONEncoder().encode(ChallengeRequest(userID: userID))
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw AppAttestError.invalidResponse
        }
        
        guard http.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AppAttestError.serverError("Challenge request failed: \(message)")
        }
        
        let challenge = try JSONDecoder().decode(String.self, from: data)
        
        guard let challengeData = Data(base64Encoded: challenge) else {
            throw AppAttestError.invalidResponse
        }
        
        logger.info("Featched challenge: \(challenge)")
        
        return challengeData
    }
    
    private func generateKey() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            service.generateKey { keyID, error in
                if let error {
                    continuation.resume(throwing: AppAttestError.keyGenerationFailed(error))
                } else if let keyID {
                    continuation.resume(returning: keyID)
                } else {
                    continuation.resume(throwing: AppAttestError.invalidResponse)
                }
            }
        }
    }
    
    private func attestKey(keyID: String, clientDataHash: Data) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            service.attestKey(keyID, clientDataHash: clientDataHash) { attestation, error in
                if let error {
                    continuation.resume(throwing: AppAttestError.attestationFailed(error))
                } else if let attestation {
                    continuation.resume(returning: attestation)
                } else {
                    continuation.resume(throwing: AppAttestError.invalidResponse)
                }
            }
        }
    }
    
    private func generateAssertion(keyID: String, clientDataHash: Data) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            service.generateAssertion(keyID, clientDataHash: clientDataHash) { assertion, error in
                if let error {
                    continuation.resume(throwing: AppAttestError.assertionFailed(error))
                } else if let assertion {
                    continuation.resume(returning: assertion)
                } else {
                    continuation.resume(throwing: AppAttestError.invalidResponse)
                }
            }
        }
    }
    
    private func verifyAttestation(challenge: Data, attestation: Data, keyID: String) async throws -> AttestationResult {
        let url = baseURL.appendingPathComponent("attest")
        
        // keyID from Apple is already base64-encoded, send as-is
        let body = AttestRequest(
            challenge: challenge.base64EncodedString(),
            attestation: attestation.base64EncodedString(),
            keyID: keyID
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw AppAttestError.invalidResponse
        }
        
        guard http.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AppAttestError.serverError("Attestation verification failed: \(message)")
        }
        
        let decoded = try JSONDecoder().decode(AttestResponse.self, from: data)
        
        return AttestationResult(
            userID: decoded.userID,
            publicKey: decoded.publicKey,
            keyID: keyID
        )
    }
    
    private func verifyAssertion(challenge: Data, assertion: Data, publicKey: String, clientData: Data) async throws -> AssertionResult {
        let url = baseURL.appendingPathComponent("assert")
        
        let body = AssertRequest(
            challenge: challenge.base64EncodedString(),
            assertion: assertion.base64EncodedString(),
            publicKey: publicKey,
            clientData: clientData.base64EncodedString()
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw AppAttestError.invalidResponse
        }
        
        guard http.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AppAttestError.serverError("Assertion verification failed: \(message)")
        }
        
        let decoded = try JSONDecoder().decode(AssertResponse.self, from: data)
        
        return AssertionResult(userID: decoded.userID, counter: decoded.counter)
    }
}

nonisolated struct AssertRequest: Encodable {
    let challenge: String
    let assertion: String
    let publicKey: String
    let clientData: String
}

nonisolated struct AssertResponse: Decodable {
    let success: Bool
    let userID: String?
    let counter: Int
}

nonisolated struct AttestResponse: Decodable {
    let success: Bool
    let userID: String?
    let publicKey: String
}
