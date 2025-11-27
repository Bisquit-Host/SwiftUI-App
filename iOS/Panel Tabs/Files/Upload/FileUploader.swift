import ScrechKit

final class FileUploader: NSObject, ObservableObject {
    @Published var uploadProgress: Float = 0
    
    private var session: URLSession!
    private var currentUploadTask: URLSessionUploadTask?
    
    func cancelUpload() {
        currentUploadTask?.cancel()
        currentUploadTask = nil
    }
    
    func uploadFile(_ urlString: String, name: String, mimeType: String, fileURL: URL) {
        let accessFiles = fileURL.startAccessingSecurityScopedResource()
        
        defer {
            if accessFiles {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
            print("Could not retrieve data from file at URL:", fileURL)
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            return
        }
        
        let boundary = "----Boundary\(UUID().uuidString)"
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let multipartData = MultipartFormData(fileData, fileName: name, mimeType: mimeType, boundary: boundary).data
        
        let tempFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        do {
            try multipartData.write(to: tempFileURL)
        } catch {
            print("Could not write multipart data to file:", error)
            return
        }
        
        let task = session.uploadTask(with: req, fromFile: tempFileURL) { _, _, _ in
            try? FileManager.default.removeItem(at: tempFileURL)
            
            Task { @MainActor in
                self.currentUploadTask = nil
            }
        }
        
        currentUploadTask = task
        task.resume()
    }
}

extension FileUploader: @preconcurrency URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        withAnimation {
            uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        }
    }
}
