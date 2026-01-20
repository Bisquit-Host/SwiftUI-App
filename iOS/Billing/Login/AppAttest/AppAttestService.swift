import Foundation
import BisquitoNet
import DeviceCheck
import CryptoKit
import OSLog

enum AppAttestError: LocalizedError {
    case notSupported,
         serverError(String),
         invalidResponse,
         keyGenerationFailed(Error),
         attestationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            "App Attest is not supported on this device"
            
        case .serverError(let message):
            message
            
        case .invalidResponse:
            "Invalid server response"
            
        case .keyGenerationFailed(let error):
            "Key generation failed: \(error)"
            
        case .attestationFailed(let error):
            "Attestation failed: \(error)"
        }
    }
}

struct AttestationResult: Encodable {
    let challenge: String
    let attestation: String
    let keyID: String
}

actor AppAttestService {
    static let shared = AppAttestService()
    
    private let service = DCAppAttestService.shared
    private let logger = Logger(subsystem: "dev.topscrech.bisquit", category: "AppAttest")
    
    private var storedKeyID: String?
    
    var isSupported: Bool {
        service.isSupported
    }
    
    func attestDevice(userID: String? = nil) async throws -> AttestationResult {
        logger.info("Starting attestation flow for userID: \(userID ?? "nil")")
        
        guard service.isSupported else {
            logger.error("App Attest not supported on this device")
            throw AppAttestError.notSupported
        }
        
        // 1. Get challenge from server
        logger.info("Step 1/4: Fetching challenge...")
        let challenge: Data
        
        do {
            challenge = try await fetchChallenge(userID: userID)
        } catch let error as AppAttestChallengeError {
            switch error {
            case .invalidResponse:
                throw AppAttestError.invalidResponse
                
            case .serverError(let message):
                throw AppAttestError.serverError(message)
            }
        } catch {
            throw AppAttestError.serverError(error.localizedDescription)
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
        
        let result = AttestationResult(
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
                    continuation.resume(throwing: AppAttestError.keyGenerationFailed(error))
                } else if let keyID {
                    logger.debug("Key generated: \(keyID)")
                    continuation.resume(returning: keyID)
                } else {
                    logger.error("Key generation returned nil")
                    continuation.resume(throwing: AppAttestError.invalidResponse)
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
                    continuation.resume(throwing: AppAttestError.attestationFailed(error))
                } else if let attestation {
                    logger.debug("Apple attestation received, size: \(attestation.count) bytes")
                    continuation.resume(returning: attestation)
                } else {
                    logger.error("Apple attestation returned nil")
                    continuation.resume(throwing: AppAttestError.invalidResponse)
                }
            }
        }
    }
}
