import ScrechKit
import Foundation

@MainActor
final class FileUploader: NSObject {
    private var progressHandler: ((Float) -> Void)?
    private(set) var uploadProgress: Float = 0 {
        didSet { progressHandler?(uploadProgress) }
    }
    
    private var session: URLSession!
    private var currentUploadTask: URLSessionUploadTask?
    
    private enum UploadError: Error {
        case failedToReadFile, failedToWriteTemp, badStatusCode(Int)
    }
    
    func cancelUpload() {
        currentUploadTask?.cancel()
        currentUploadTask = nil
    }
    
    func setProgressHandler(_ handler: @escaping (Float) -> Void) {
        progressHandler = handler
    }
    
    func uploadFile(_ url: URL, name: String, mimeType: String, fileURL: URL) async throws {
        let accessFiles = fileURL.startAccessingSecurityScopedResource()
        
        defer {
            if accessFiles {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
            throw UploadError.failedToReadFile
        }
        
        let boundary = "----Boundary\(UUID().uuidString)"
        let config = URLSessionConfiguration.default
        
        // Deliver delegate callbacks on main to align with MainActor isolation
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let multipartData = MultipartFormData(fileData, fileName: name, mimeType: mimeType, boundary: boundary).data
        
        let tempFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        do {
            try multipartData.write(to: tempFileURL)
        } catch {
            throw UploadError.failedToWriteTemp
        }
        
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let task = session.uploadTask(with: req, fromFile: tempFileURL) { _, response, error in
                    try? FileManager.default.removeItem(at: tempFileURL)
                    
                    Task { @MainActor in
                        self.currentUploadTask = nil
                    }
                    
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let http = response as? HTTPURLResponse,
                       !(200..<300).contains(http.statusCode) {
                        continuation.resume(throwing: UploadError.badStatusCode(http.statusCode))
                        return
                    }
                    
                    continuation.resume(returning: ())
                }
                
                currentUploadTask = task
                task.resume()
            }
        } onCancel: {
            Task { @MainActor in
                currentUploadTask?.cancel()
            }
        }
    }
}

extension FileUploader: @preconcurrency URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    }
}
