import Foundation
import Network

/// Sends a TCP ping by attempting a connection to the specified host and port
/// It measures the time taken to establish the connection, which serves as the round-trip time
/// - Parameters:
///   - host: The hostname or IP address to ping
///   - port: The TCP port to connect to
///   - timeout: Maximum time to wait for the connection, in seconds (default is 5)
///   - completion: A closure called with a Result containing either the elapsed
///     time (in seconds) on success or an Error on failure
public func tcpPing(host: String, port: UInt16, timeout: TimeInterval = 5, completion: @escaping @Sendable (Result<TimeInterval, Error>) -> Void) {
    let startTime = Date()
    
    actor FinishState {
        private var didFinish = false
        
        func markFinished() -> Bool {
            guard !didFinish else { return false }
            didFinish = true
            return true
        }
    }
    
    struct UncheckedSendable<Value>: @unchecked Sendable {
        let value: Value
    }
    
    let finishState = FinishState()
    
    guard let nwPort = NWEndpoint.Port(rawValue: port) else {
        let error = NSError(
            domain: "TCPPingError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Invalid port number"]
        )
        
        completion(.failure(error))
        return
    }
    
    let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
    let connectionBox = UncheckedSendable(value: connection)
    let completionBox = UncheckedSendable(value: completion)
    
    let finish: @Sendable (Result<TimeInterval, Error>) -> Void = { result in
        Task {
            guard await finishState.markFinished() else { return }
            await connectionBox.value.cancel()
            await completionBox.value(result)
        }
    }
    
    connection.stateUpdateHandler = { state in
        switch state {
        case .ready:
            let elapsed = Date().timeIntervalSince(startTime)
            finish(.success(elapsed))
            
        case .failed(let nwError): // Use a different identifier to avoid conflicts
            finish(.failure(nwError))
            
        default:
            break
        }
    }
    
    connection.start(queue: DispatchQueue.global())
    
    DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
        let timeoutError = NSError(
            domain: "TCPPingError",
            code: -1001,
            userInfo: [NSLocalizedDescriptionKey: "Connection timed out"]
        )
        
        finish(.failure(timeoutError))
    }
}

/// An async version of `tcpPing(host:port:timeout:completion:)`
/// Requires iOS 15/macOS 12 or later
/// - Parameters:
///   - host: The hostname or IP address to ping
///   - port: The TCP port to connect to
///   - timeout: Maximum time to wait for the connection (default is 5 seconds)
/// - Returns: The measured round-trip time in seconds
/// - Throws: An error if the connection fails or times out
public func tcpPing(host: String, port: UInt16, timeout: TimeInterval = 5) async throws -> TimeInterval {
    try await withCheckedThrowingContinuation { continuation in
        tcpPing(host: host, port: port, timeout: timeout) { result in
            continuation.resume(with: result)
        }
    }
}
