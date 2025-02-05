import ScrechKit

final class FileUploader: NSObject, ObservableObject {
    @Published var uploadProgress: Float = 0
    
    private var session: URLSession!
    private var currentUploadTask: URLSessionUploadTask?
    
    func uploadFile(
        _ urlString: String,
        name: String,
        mimeType: String,
        fileUrl: URL
    ) {
        let accessFiles = fileUrl.startAccessingSecurityScopedResource()
        
        defer {
            if accessFiles {
                fileUrl.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let fileData = try? Data(contentsOf: fileUrl) else {
            print("Could not retrieve data from file at URL: \(fileUrl)")
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let boundary = "----Boundary\(UUID().uuidString)"
        let config = URLSessionConfiguration.default
        
        self.session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let multipartData = MultipartFormData(fileData, fileName: name, mimeType: mimeType, boundary: boundary).data
        
        let tempFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try multipartData.write(to: tempFileUrl)
        } catch {
            print("Could not write multipart data to file: \(error)")
            return
        }
        
        let task = session.uploadTask(with: request, fromFile: tempFileUrl) { [weak self] data, response, error in
            try? FileManager.default.removeItem(at: tempFileUrl)
            self?.currentUploadTask = nil
        }
        
        currentUploadTask = task
        task.resume()
    }
    
    func cancelUpload() {
        currentUploadTask?.cancel()
        currentUploadTask = nil
    }
}

extension FileUploader: URLSessionDataDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        main { [self] in
            withAnimation {
                uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            }
        }
    }
}

struct MultipartFormData {
    var data: Data
    
    init(
        _ fileData: Data,
        fileName: String,
        mimeType: String,
        boundary: String
    ) {
        var fullData = Data()
        
        if let boundaryData = "--\(boundary)\r\n".data(using: .utf8) {
            fullData.append(boundaryData)
        }
        
        if let contentDisposition = "Content-Disposition: form-data; name=\"files\"; filename=\"\(fileName)\"\r\n".data(using: .utf8) {
            fullData.append(contentDisposition)
        }
        
        if let contentType = "Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8) {
            fullData.append(contentType)
        }
        
        fullData.append(fileData)
        
        if let closingData = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
            fullData.append(closingData)
        }
        
        data = fullData
    }
}
