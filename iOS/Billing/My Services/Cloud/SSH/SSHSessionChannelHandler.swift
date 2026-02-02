import NIOSSH
import NIOCore

final class SSHSessionChannelHandler: ChannelInboundHandler {
    typealias InboundIn = SSHChannelData
    
    nonisolated private let log: @Sendable (String) -> Void
    nonisolated private let onOutput: @Sendable (ArraySlice<UInt8>) -> Void
    nonisolated private let onError: @Sendable (Error) -> Void
    nonisolated private let onInactive: @Sendable () -> Void
    
    nonisolated init(
        log: @escaping @Sendable (String) -> Void,
        onOutput: @escaping @Sendable (ArraySlice<UInt8>) -> Void,
        onError: @escaping @Sendable (Error) -> Void,
        onInactive: @escaping @Sendable () -> Void
    ) {
        self.log = log
        self.onOutput = onOutput
        self.onError = onError
        self.onInactive = onInactive
    }
    
    nonisolated func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = self.unwrapInboundIn(data)
        guard channelData.type == .channel || channelData.type == .stdErr else { return }
        
        switch channelData.data {
        case .byteBuffer(var buffer):
            if let bytes = buffer.readBytes(length: buffer.readableBytes), !bytes.isEmpty {
                self.log("ssh: recv \(bytes.count) bytes")
                self.onOutput(bytes[...])
            }
        case .fileRegion:
            break
        }
    }
    
    nonisolated func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        switch event {
        case is SSHChannelRequestEvent.ExitStatus,
            is SSHChannelRequestEvent.ExitSignal,
            is ChannelSuccessEvent,
            is ChannelFailureEvent:
            break
        default:
            break
        }
        
        context.fireUserInboundEventTriggered(event)
    }
    
    nonisolated func channelInactive(context: ChannelHandlerContext) {
        self.log("ssh: session channel inactive")
        self.onInactive()
        context.fireChannelInactive()
    }
    
    nonisolated func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.log("ssh: session channel error \(String(reflecting: error))")
        self.onError(error)
        context.close(promise: nil)
    }
}
