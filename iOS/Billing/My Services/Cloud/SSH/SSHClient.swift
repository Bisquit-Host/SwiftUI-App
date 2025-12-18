import Foundation
import NIOSSH
import NIOCore
import NIOPosix
import NIOConcurrencyHelpers

final class SSHClient {
    private let lock = NIOLock()
    private var state: SSHState = .idle
    
    private var group: EventLoopGroup?
    private var parentChannel: Channel?
    private var sessionChannel: Channel?
    
    var onLog: (@Sendable (String) -> Void)?
    var onOutput: (@Sendable (ArraySlice<UInt8>) -> Void)?
    var onStateChange: (@Sendable (SSHState) -> Void)?
    var onError: (@Sendable (Error) -> Void)?
    
    func connect(_ info: SSHConnectionInfo, initialCols: Int, initialRows: Int) async throws {
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
        
        setState(.connecting)
        log("eventloop: starting")
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        lock.withLock {
            self.group = group
        }
        
        do {
            let bootstrap = ClientBootstrap(group: group)
                .channelInitializer { channel in
                    log("parent channel: initializing pipeline")
                    
                    let userAuth = LoggingPasswordAuthDelegate(info, log: log)
                    
                    let serverAuth = AcceptAllHostKeysDelegate(log: log)
                    let config = SSHClientConfiguration(userAuthDelegate: userAuth, serverAuthDelegate: serverAuth)
                    
                    let sshHandler = NIOSSHHandler(role: .client(config), allocator: channel.allocator, inboundChildChannelInitializer: nil)
                    
                    do {
                        try channel.pipeline.syncOperations.addHandlers(
                            ParentChannelLifecycleHandler(
                                log: log,
                                onError: errorHandler
                            ),
                            sshHandler
                        )
                        return channel.eventLoop.makeSucceededVoidFuture()
                    } catch {
                        return channel.eventLoop.makeFailedFuture(error)
                    }
                }
            
            log("connect: dialing \(info.host):\(info.port)")
            
            let parentChannel = try await bootstrap.connect(host: info.host, port: info.port).get()
            
            if let local = parentChannel.localAddress, let remote = parentChannel.remoteAddress {
                log("connect: tcp connected local=\(local) remote=\(remote)")
            } else {
                log("connect: tcp connected")
            }
            
            lock.withLock {
                self.parentChannel = parentChannel
            }
            
            log("ssh: creating session channel")
            
            let sessionChannel = try await parentChannel.pipeline
                .handler(type: NIOSSHHandler.self)
                .flatMap { sshHandler in
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
                .get()
            
            lock.withLock {
                self.sessionChannel = sessionChannel
            }
            
            log("ssh: requesting pty cols=\(initialCols) rows=\(initialRows)")
            try await requestPTYAndShell(cols: initialCols, rows: initialRows)
            
            log("ssh: pty + shell ready")
            setState(.connected)
        } catch {
            log("connect failed: \(String(reflecting: error))")
            await safeShutdownGroup()
            
            setState(.disconnected)
            throw error
        }
    }
    
    func disconnect() async throws {
        let (channel, group) = lock.withLock { (self.parentChannel, self.group) }
        
        if let channel {
            onLog?("disconnect: closing parent channel")
            try? await channel.close(mode: .all)
        }
        
        if group != nil {
            onLog?("eventloop: shutdown")
            await safeShutdownGroup()
        }
        
        lock.withLock {
            parentChannel = nil
            sessionChannel = nil
            self.group = nil
        }
        
        setState(.disconnected)
    }
    
    func send(_ data: ArraySlice<UInt8>) {
        let channel = lock.withLock { sessionChannel }
        guard let channel else { return }
        
        channel.eventLoop.execute {
            var buffer = channel.allocator.buffer(capacity: data.count)
            buffer.writeBytes(data)
            channel.writeAndFlush(SSHChannelData(type: .channel, data: .byteBuffer(buffer)), promise: nil)
        }
    }
    
    func resize(cols: Int, rows: Int) {
        let channel = lock.withLock { sessionChannel }
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
    
    private func requestPTYAndShell(cols: Int, rows: Int) async throws {
        let channel = self.lock.withLock { sessionChannel }
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
        let group = lock.withLock { self.group }
        guard let group else { return }
        
        try? await group.shutdownGracefully()
    }
    
    private func setState(_ newState: SSHState) {
        lock.withLock {
            state = newState
        }
        
        onStateChange?(newState)
    }
}
