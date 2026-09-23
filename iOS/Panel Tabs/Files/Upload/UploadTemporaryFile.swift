import Foundation
import OSLog

enum UploadTemporaryFile {
    static func write(_ data: Data, pathExtension: String) throws -> URL {
        let url = URL.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension(pathExtension)

        try data.write(to: url, options: .atomic)
        return url
    }

    static func remove(_ urls: [URL]) {
        for url in urls {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                Logger().error("Unable to remove upload temporary file: \(error)")
            }
        }
    }
}
