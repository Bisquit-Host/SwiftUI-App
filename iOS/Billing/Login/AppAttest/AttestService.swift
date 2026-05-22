import Foundation
import BisquitoNet
import DeviceCheck
import CryptoKit
import OSLog

actor AttestService {
    static let shared = AttestService()
    
    private let service = DCAppAttestService.shared
    private let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "AppAttest")
    
    private var storedKeyID: String?
    
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
            challenge = try await fetchChallenge(userID: userID)
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
        
        // 2. Generate key
        logger.info("Step 2/4: Generating key...")
        let keyID = try await generateKey()
        logger.info("Step 2/4: Key generated")
        
        // 3. Hash the challenge for attestation
        logger.info("Step 3/4: Hashing challenge...")
        let challengeHash = Data(SHA256.hash(data: challenge))
        logger.debug("Challenge hash: \(challengeHash.base64EncodedString())")
        
        // 4. Attest the key with Apple
        logger.info("Step 4/4: Attesting with Apple...")
        let attestation = try await attestKey(keyID: keyID, clientDataHash: challengeHash)
        logger.info("Step 4/4: Apple attestation received")
        
        // Store for later assertions
        storedKeyID = keyID
        
        let result = AttestResult(
            challenge: challenge.base64EncodedString(),
            attestation: attestation.base64EncodedString(),
            keyID: keyID
        )
        
        logger.info("Attestation complete - ready to send with login request")
        
        return result
    }
    
    // MARK: - Private Methods
    
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
}
