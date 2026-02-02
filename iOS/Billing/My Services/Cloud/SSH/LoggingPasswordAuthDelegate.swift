import NIOSSH
import NIOCore
import NIOConcurrencyHelpers

final class LoggingPasswordAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
    nonisolated private let username: String
    nonisolated private let password: String
    nonisolated private let log: @Sendable (String) -> Void
    nonisolated private let attemptLock = NIOLock()
    nonisolated(unsafe) private var hasAttempted = false
    
    nonisolated init(_ info: SSHConnectionInfo, log: @escaping @Sendable (String) -> Void) {
        self.username = info.username
        self.password = info.password
        self.log = log
    }
    
    nonisolated func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        self.log("ssh: auth methods offered: password=\(availableMethods.contains(.password)) publicKey=\(availableMethods.contains(.publicKey)) hostBased=\(availableMethods.contains(.hostBased))")
        let canAttempt = self.attemptLock.withLock {
            if hasAttempted {
                return false
            }
            
            hasAttempted = true
            return true
        }
        
        guard canAttempt else {
            self.log("ssh: auth: no more attempts")
            nextChallengePromise.succeed(nil)
            return
        }
        
        guard availableMethods.contains(.password) else {
            self.log("ssh: auth: password not supported by server")
            nextChallengePromise.succeed(nil)
            return
        }
        
        self.log("ssh: auth: attempting password for user=\(username)")
        
        nextChallengePromise.succeed(
            NIOSSHUserAuthenticationOffer(username: username, serviceName: "", offer: .password(.init(password: password)))
        )
    }
}
