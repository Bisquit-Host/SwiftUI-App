//import SwiftUI
//import AppleArchive
//import System
//
//@Observable
//class Archieving {
//    func decompress(_ archivePath: String) -> URL? {
//        // Validate file existence
//        guard FileManager.default.fileExists(atPath: archivePath) else {
//            print("File does not exist at path:", archivePath)
//            return nil
//        }
//        
//        // Validate file contents
//        if let fileData = FileManager.default.contents(atPath: archivePath) {
//            print("File size: \(fileData.count) bytes")
//        } else {
//            print("Failed to read file data at path:", archivePath)
//            return nil
//        }
//        
//        // File Read Stream
//        guard let readFileStream = ArchiveByteStream.fileStream(
//            path: FilePath(archivePath),
//            mode: .readOnly,
//            options: [],
//            permissions: .init(rawValue: 0o644)
//        ) else {
//            print("Failed to open file read stream")
//            return nil
//        }
//        
//        defer {
//            try? readFileStream.close()
//        }
//        
//        // Decompression Stream
//        guard let decompressStream = ArchiveByteStream.decompressionStream(
//            readingFrom: readFileStream
//        ) else {
//            print("Failed to open decompression stream")
//            return nil
//        }
//        
//        defer {
//            try? decompressStream.close()
//        }
//        
//        // Decoding Stream
//        guard let decodeStream = ArchiveStream.decodeStream(
//            readingFrom: decompressStream
//        ) else {
//            print("Failed to create decode stream")
//            return nil
//        }
//        
//        defer {
//            try? decodeStream.close()
//        }
//        
//        // Destination
//        let decompressPath = NSTemporaryDirectory() + "dest/"
//        
//        do {
//            if !FileManager.default.fileExists(atPath: decompressPath) {
//                try FileManager.default.createDirectory(
//                    atPath: decompressPath,
//                    withIntermediateDirectories: false
//                )
//            }
//        } catch {
//            print("Failed to create destination directory:", error.localizedDescription)
//            return nil
//        }
//        
//        let decompressDestination = FilePath(decompressPath)
//        
//        // Extract Stream
//        guard let extractStream = ArchiveStream.extractStream(
//            extractingTo: decompressDestination,
//            flags: [.ignoreOperationNotPermitted]
//        ) else {
//            print("Failed to create extract stream")
//            return nil
//        }
//        
//        defer {
//            try? extractStream.close()
//        }
//        
//        // Decompress and extract
//        do {
//            _ = try ArchiveStream.process(
//                readingFrom: decodeStream,
//                writingTo: extractStream
//            )
//            
//            print("Decompression successful to path:", decompressPath)
//            return URL(fileURLWithPath: decompressPath)
//        } catch {
//            print("Decompression and extraction failed:", error.localizedDescription)
//            return nil
//        }
//    }
//}
