import ScrechKit
import PteroNet

final class WebSocketTaskConnection: NSObject, WebSocketConnection, URLSessionWebSocketDelegate {
    private let url: URL
    private let token: String
    
    init(_ url: URL, token: String) {
        self.url = url
        self.token = token
        super.init()
        
        urlSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: delegateQueue
        )
        
        var request = URLRequest(url: url)
        request.setValue("https://mgr.bisquit.host", forHTTPHeaderField: "Origin")
        
        webSocketTask = urlSession.webSocketTask(with: request)
    }
    
    var delegate: WebSocketConnectionDelegate?
    var webSocketTask: URLSessionWebSocketTask!
    var urlSession: URLSession!
    private let delegateQueue = OperationQueue()
    
    private var state: WebSocketConnectionState = .disconnected {
        didSet {
            delegate?.onStateChanged(
                connection: self,
                state: state
            )
        }
    }
    
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        self.delegate?.onConnecting(connection: self)
        
        webSocketTask.send(.string("{\"event\":\"auth\",\"args\":[\"\(token)\"]}")) { error in
            if let error {
                self.delegate?.onError(
                    connection: self,
                    error: error
                )
            }
        }
        
        delay(0.5) {
            webSocketTask.send(.string("{\"event\":\"send logs\",\"args\":[\"null\"]}")) { error in
                if let error {
                    self.delegate?.onError(
                        connection: self,
                        error: error
                    )
                }
            }
        }
    }
    
    func connect() {
        guard state == .disconnected else {
            return
        }
        
        state = .connecting
        delegate?.onConnecting(connection: self)
        webSocketTask.resume()
        listen()
    }
    
    func disconnect() {
        guard state != .disconnected else {
            return
        }
        
        delegate?.onDisconnecting(connection: self)
        state = .disconnected
        
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func send(_ text: String) {
        guard state == .connected else {
            return
        }
        
        webSocketTask.send(.string(text)) { error in
            if let error {
                self.delegate?.onError(
                    connection: self,
                    error: error
                )
            }
        }
    }
    
    func send(_ data: Data) {
        guard state == .connected else {
            return
        }
        
        webSocketTask.send(.data(data)) { error in
            if let error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
    
    func listen() {
        webSocketTask.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.delegate?.onError(
                    connection: self!,
                    error: error
                )
                
                self?.disconnect()
                
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.delegate?.onTextMessage(
                        connection: self!,
                        message: text
                    )
                    
                case .data(let data):
                    self?.delegate?.onDataMessage(
                        connection: self!,
                        message: data
                    )
                    
                default:
                    fatalError("Received unknown message type")
                }
                
                self?.listen()
            }
        }
    }
}
