import NIOSSH
import NIOCore

final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    nonisolated private let log: @Sendable (String) -> Void
    
    nonisolated init(log: @escaping @Sendable (String) -> Void) {
        self.log = log
    }
    
    nonisolated func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        self.log("ssh: hostkey accepted \(String(openSSHPublicKey: hostKey))")
        validationCompletePromise.succeed(())
    }
}
