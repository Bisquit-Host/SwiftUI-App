import NIOCore

final class ParentChannelLifecycleHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    
    nonisolated private let log: @Sendable (String) -> Void
    nonisolated private let onError: @Sendable (Error) -> Void
    
    nonisolated init(log: @escaping @Sendable (String) -> Void, onError: @escaping @Sendable (Error) -> Void) {
        self.log = log
        self.onError = onError
    }
    
    nonisolated func channelActive(context: ChannelHandlerContext) {
        self.log("parent channel: active")
        context.fireChannelActive()
    }
    
    nonisolated func channelInactive(context: ChannelHandlerContext) {
        self.log("parent channel: inactive")
        context.fireChannelInactive()
    }
    
    nonisolated func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.log("parent channel error: \(String(reflecting: error))")
        self.onError(error)
        context.fireErrorCaught(error)
    }
}
