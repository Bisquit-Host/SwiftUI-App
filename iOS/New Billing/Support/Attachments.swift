import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

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
}

enum AttachmentFactory {
    static func from(url: URL) -> PendingAttachment? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let ext = url.pathExtension.lowercased()
        let mime = mimeType(for: ext)
        
        return PendingAttachment(filename: url.lastPathComponent, contentType: mime, data: data)
    }
    
    static func from(photoItem: PhotosPickerItem) async -> PendingAttachment? {
        guard let data = try? await photoItem.loadTransferable(type: Data.self) else { return nil }
        
        let mime = photoItem.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
        let suggested = photoItem.itemIdentifier?.suggestedFilename ?? "photo-\(UUID().uuidString).jpg"
        let filename = suggested.contains(".") ? suggested : suggested + ".jpg"
        
        return PendingAttachment(filename: filename, contentType: mime, data: data)
    }
    
    static func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "png": "image/png"
        case "jpg", "jpeg": "image/jpeg"
        case "gif": "image/gif"
        case "svg": "image/svg+xml"
        case "webp": "image/webp"
        case "txt": "text/plain"
        case "js": "text/javascript"
        case "php": "application/x-httpd-php"
        case "py": "text/x-python"
        case "json": "application/json"
        case "md": "text/markdown"
        default: "application/octet-stream"
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
