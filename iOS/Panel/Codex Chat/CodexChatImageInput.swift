import Foundation
import UniformTypeIdentifiers

struct CodexChatImageInput: Identifiable, Hashable, Encodable, Sendable {
    nonisolated static let maxCount = 4
    nonisolated static let maxBytes = 5 * 1024 * 1024
    nonisolated static let allowedContentTypes: [UTType] = [.png, .jpeg, .gif, .webP]

    let id: UUID
    let name: String
    let mediaType: String
    let data: Data

    nonisolated var dataURL: String {
        "data:\(mediaType);base64,\(data.base64EncodedString())"
    }

    nonisolated init(id: UUID = UUID(), name: String, data: Data) throws {
        guard data.count <= Self.maxBytes else {
            throw CodexChatImageInputError.tooLarge(name)
        }

        guard let mediaType = Self.mediaType(for: data) else {
            throw CodexChatImageInputError.unsupported(name)
        }

        self.id = id
        self.name = name
        self.mediaType = mediaType
        self.data = data
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([
            "name": name,
            "data_url": dataURL,
        ])
    }

    nonisolated static func from(url: URL) throws -> CodexChatImageInput {
        let accessingSecurityScopedResource = url.startAccessingSecurityScopedResource()
        defer {
            if accessingSecurityScopedResource {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        if let fileSize, fileSize > maxBytes {
            throw CodexChatImageInputError.tooLarge(url.lastPathComponent)
        }

        return try CodexChatImageInput(name: url.lastPathComponent, data: Data(contentsOf: url))
    }

    nonisolated private static func mediaType(for data: Data) -> String? {
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
            return "image/png"
        }

        if data.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "image/jpeg"
        }

        if data.starts(with: Data("GIF87a".utf8)) || data.starts(with: Data("GIF89a".utf8)) {
            return "image/gif"
        }

        if data.count >= 12,
           data.starts(with: Data("RIFF".utf8)),
           data.subdata(in: 8..<12) == Data("WEBP".utf8) {
            return "image/webp"
        }

        return nil
    }
}
