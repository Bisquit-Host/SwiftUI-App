import Foundation

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
        
        let contentDisposition = "Content-Disposition: form-data; name=\"files\"; filename=\"\(fileName)\"\r\n"
        if let contentDispositionData = contentDisposition.data(using: .utf8) {
            fullData.append(contentDispositionData)
        }
        
        let contentType = "Content-Type: \(mimeType)\r\n\r\n"
        if let contentTypeData = contentType.data(using: .utf8) {
            fullData.append(contentTypeData)
        }
        
        fullData.append(fileData)
        
        let closing = "\r\n--\(boundary)--\r\n"
        if let closingData = closing.data(using: .utf8) {
            fullData.append(closingData)
        }
        
        data = fullData
    }
}
