#if canImport(NIOSSH)
import Foundation
import NIOConcurrencyHelpers
import NIOCore
import NIOPosix
import NIOSSH

final class SSHClient {
    enum State: Equatable {
        case idle
        case connecting
        case connected
        case disconnected
    }

    struct ConnectionInfo: Equatable {
        var host: String
        var port: Int
        var username: String
        var password: String
    }

    private let lock = NIOLock()
    private var state: State = .idle

    private var group: EventLoopGroup?
    private var parentChannel: Channel?
    private var sshHandler: NIOSSHHandler?
    private var sessionChannel: Channel?

    var onLog: (@Sendable (String) -> Void)?
    var onOutput: (@Sendable (ArraySlice<UInt8>) -> Void)?
    var onStateChange: (@Sendable (State) -> Void)?
    var onError: (@Sendable (Error) -> Void)?

    func connect(_ info: ConnectionInfo, initialCols: Int, initialRows: Int) async throws {
        try await disconnect()

        let log: @Sendable (String) -> Void = { [onLog] message in
            onLog?(message)
        }
        let output: @Sendable (ArraySlice<UInt8>) -> Void = { [onOutput] bytes in
            onOutput?(bytes)
        }
        let errorHandler: @Sendable (Error) -> Void = { [onError] error in
            onError?(error)
        }
        let onInactive: @Sendable () -> Void = { [weak self] in
            Task { @MainActor in
                self?.setState(.disconnected)
            }
        }

        self.setState(.connecting)
        log("eventloop: starting")

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.lock.withLock {
            self.group = group
        }

        do {
            let bootstrap = ClientBootstrap(group: group)
                .channelInitializer { channel in
                    log("parent channel: initializing pipeline")

                    let userAuth = LoggingPasswordAuthDelegate(
                        username: info.username,
                        password: info.password,
                        log: log
                    )
                    
                    let serverAuth = AcceptAllHostKeysDelegate(log: log)
                    let config = SSHClientConfiguration(userAuthDelegate: userAuth, serverAuthDelegate: serverAuth)

                    let sshHandler = NIOSSHHandler(
                        role: .client(config),
                        allocator: channel.allocator,
                        inboundChildChannelInitializer: nil
                    )

                    return channel.pipeline.addHandlers([
                        ParentChannelLifecycleHandler(
                            log: log,
                            onError: errorHandler
                        ),
                        sshHandler,
                    ])
                }

            log("connect: dialing \(info.host):\(info.port)")
            let parentChannel = try await bootstrap.connect(host: info.host, port: info.port).get()
            if let local = parentChannel.localAddress, let remote = parentChannel.remoteAddress {
                log("connect: tcp connected local=\(local) remote=\(remote)")
            } else {
                log("connect: tcp connected")
            }
            self.lock.withLock {
                self.parentChannel = parentChannel
            }

            let sshHandler = try await parentChannel.pipeline.handler(type: NIOSSHHandler.self).get()
            self.lock.withLock {
                self.sshHandler = sshHandler
            }

            log("ssh: creating session channel")
            let sessionChannel = try await parentChannel.eventLoop
                .submit { () -> EventLoopFuture<Channel> in
                    let promise = parentChannel.eventLoop.makePromise(of: Channel.self)
                    sshHandler.createChannel(promise, channelType: .session) { childChannel, _ in
                        childChannel.setOption(ChannelOptions.allowRemoteHalfClosure, value: true).flatMap {
                            childChannel.pipeline.addHandler(
                                SSHSessionChannelHandler(
                                    log: log,
                                    onOutput: output,
                                    onError: errorHandler,
                                    onInactive: onInactive
                                )
                            )
                        }
                    }
                    return promise.futureResult
                }
                .flatMap { $0 }
                .get()

            self.lock.withLock {
                self.sessionChannel = sessionChannel
            }

            log("ssh: requesting pty cols=\(initialCols) rows=\(initialRows)")
            try await self.requestPTYAndShell(cols: initialCols, rows: initialRows)
            log("ssh: pty + shell ready")
            self.setState(.connected)
        } catch {
            log("connect failed: \(String(reflecting: error))")
            await self.safeShutdownGroup()
            self.setState(.disconnected)
            throw error
        }
    }

    func disconnect() async throws {
        let (channel, group) = self.lock.withLock { (self.parentChannel, self.group) }
        if let channel {
            self.onLog?("disconnect: closing parent channel")
            try? await channel.close(mode: .all)
        }
        if group != nil {
            self.onLog?("eventloop: shutdown")
            await self.safeShutdownGroup()
        }

        self.lock.withLock {
            self.parentChannel = nil
            self.sshHandler = nil
            self.sessionChannel = nil
            self.group = nil
        }

        self.setState(.disconnected)
    }

    func send(_ data: ArraySlice<UInt8>) {
        let channel = self.lock.withLock { self.sessionChannel }
        guard let channel else { return }

        channel.eventLoop.execute {
            var buffer = channel.allocator.buffer(capacity: data.count)
            buffer.writeBytes(data)
            channel.writeAndFlush(SSHChannelData(type: .channel, data: .byteBuffer(buffer)), promise: nil)
        }
    }

    func resize(cols: Int, rows: Int) {
        let channel = self.lock.withLock { self.sessionChannel }
        guard let channel else { return }

        channel.eventLoop.execute {
            channel.triggerUserOutboundEvent(
                SSHChannelRequestEvent.WindowChangeRequest(
                    terminalCharacterWidth: cols,
                    terminalRowHeight: rows,
                    terminalPixelWidth: 0,
                    terminalPixelHeight: 0
                ),
                promise: nil
            )
        }
    }

    // MARK: - Private

    private func requestPTYAndShell(cols: Int, rows: Int) async throws {
        let channel = self.lock.withLock { self.sessionChannel }
        guard let channel else { return }

        try await channel.eventLoop
            .submit { () -> EventLoopFuture<Void> in
                let pty = SSHChannelRequestEvent.PseudoTerminalRequest(
                    wantReply: true,
                    term: "xterm-256color",
                    terminalCharacterWidth: cols,
                    terminalRowHeight: rows,
                    terminalPixelWidth: 0,
                    terminalPixelHeight: 0,
                    terminalModes: SSHTerminalModes([:])
                )

                let ptyPromise = channel.eventLoop.makePromise(of: Void.self)
                channel.triggerUserOutboundEvent(pty, promise: ptyPromise)

                return ptyPromise.futureResult.flatMap {
                    let shellPromise = channel.eventLoop.makePromise(of: Void.self)
                    channel.triggerUserOutboundEvent(SSHChannelRequestEvent.ShellRequest(wantReply: true), promise: shellPromise)
                    return shellPromise.futureResult
                }
            }
            .flatMap { $0 }
            .get()
    }

    private func safeShutdownGroup() async {
        let group = self.lock.withLock { self.group }
        guard let group else { return }
        try? await group.shutdownGracefully()
    }

    private func setState(_ newState: State) {
        self.lock.withLock {
            self.state = newState
        }
        self.onStateChange?(newState)
    }
}

private enum SSHClientError: Error, LocalizedError {
    case internalInvariantViolated(String)

    var errorDescription: String? {
        switch self {
        case .internalInvariantViolated(let message):
            return "SSH internal error: \(message)"
        }
    }
}

private final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    nonisolated private let log: @Sendable (String) -> Void

    init(log: @escaping @Sendable (String) -> Void) {
        self.log = log
    }

    nonisolated func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        self.log("ssh: hostkey accepted \(String(openSSHPublicKey: hostKey))")
        validationCompletePromise.succeed(())
    }
}

private final class LoggingPasswordAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
    nonisolated private let username: String
    nonisolated private let password: String
    nonisolated private let log: @Sendable (String) -> Void
    nonisolated private let attemptLock = NIOLock()
    nonisolated(unsafe) private var hasAttempted = false

    init(username: String, password: String, log: @escaping @Sendable (String) -> Void) {
        self.username = username
        self.password = password
        self.log = log
    }

    nonisolated func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        self.log("ssh: auth methods offered: password=\(availableMethods.contains(.password)) publicKey=\(availableMethods.contains(.publicKey)) hostBased=\(availableMethods.contains(.hostBased))")
        let canAttempt = self.attemptLock.withLock {
            if self.hasAttempted {
                return false
            }
            self.hasAttempted = true
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

        self.log("ssh: auth: attempting password for user=\(self.username)")
        nextChallengePromise.succeed(
            NIOSSHUserAuthenticationOffer(
                username: self.username,
                serviceName: "",
                offer: .password(.init(password: self.password))
            )
        )
    }
}

private final class ParentChannelLifecycleHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer

    nonisolated private let log: @Sendable (String) -> Void
    nonisolated private let onError: @Sendable (Error) -> Void

    init(log: @escaping @Sendable (String) -> Void, onError: @escaping @Sendable (Error) -> Void) {
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

private final class SSHSessionChannelHandler: ChannelInboundHandler {
    typealias InboundIn = SSHChannelData

    nonisolated private let log: @Sendable (String) -> Void
    nonisolated private let onOutput: @Sendable (ArraySlice<UInt8>) -> Void
    nonisolated private let onError: @Sendable (Error) -> Void
    nonisolated private let onInactive: @Sendable () -> Void

    init(
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
#endif
