import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum AttachmentLimits {
    static let maxBytes = 5 * 1024 * 1024
    
    static func readableSize(for bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct PendingAttachment: Identifiable, Hashable {
    let id = UUID()
    let filename: String
    let contentType: String
    let data: Data
    
    var readableSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(data.count))
    }
    
    var isTooLarge: Bool {
        data.count > AttachmentLimits.maxBytes
    }
}

enum AttachmentFactory {
    static func from(url: URL) -> PendingAttachment? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard validateSize(data, filename: url.lastPathComponent) else { return nil }
        
        let fileExtension = url.pathExtension.lowercased()
        let mime = mimeType(for: fileExtension)
        
        return PendingAttachment(filename: url.lastPathComponent, contentType: mime, data: data)
    }
    
    static func from(photoItem: PhotosPickerItem) async -> PendingAttachment? {
        guard let data = try? await photoItem.loadTransferable(type: Data.self) else { return nil }
        
        let mime = photoItem.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
        let suggested = photoItem.itemIdentifier?.suggestedFilename ?? "photo-\(UUID().uuidString).jpg"
        let filename = suggested.contains(".") ? suggested : suggested + ".jpg"
        
        guard validateSize(data, filename: filename) else { return nil }
        
        return PendingAttachment(filename: filename, contentType: mime, data: data)
    }
    
    private static func validateSize(_ data: Data, filename: String) -> Bool {
        guard data.count <= AttachmentLimits.maxBytes else {
            let sizeString = AttachmentLimits.readableSize(for: data.count)
            let limitString = AttachmentLimits.readableSize(for: AttachmentLimits.maxBytes)
            
            SystemAlert.error("File too large", subtitle: "\(filename) is \(sizeString). Max \(limitString) per file")
            return false
        }
        
        return true
    }
    
    static func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "png":  "image/png"
        case "jpg",  "jpeg": "image/jpeg"
        case "gif":  "image/gif"
        case "svg":  "image/svg+xml"
        case "webp": "image/webp"
        case "txt":  "text/plain"
        case "js":   "text/javascript"
        case "php":  "application/x-httpd-php"
        case "py":   "text/x-python"
        case "json": "application/json"
        case "md":   "text/markdown"
        default:     "application/octet-stream"
        }
    }
}

enum AttachmentPicker {
    static let allowedExtensions = ["png","jpg","jpeg","gif","svg","webp","txt","js","php","py","json","md"]
    
    static var allowedTypes: [UTType] {
        var types = allowedExtensions.compactMap { UTType(filenameExtension: $0) }
        types.append(.image)
        
        return types
    }
}
