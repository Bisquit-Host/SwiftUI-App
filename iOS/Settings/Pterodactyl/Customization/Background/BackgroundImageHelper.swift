import SwiftUI
import os

final class BackgroundImageHelper {
    static func getDocumentsDir() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.heicData() else {
            Logger().error("Could not get HEIC data from image")
            return nil
        }
        
        let fileName = UUID().uuidString + ".heic"
        let fileURL = getDocumentsDir().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            Logger().info("Image saved at: \(fileURL.path)")
            
            // Return only the file name
            return fileName
        } catch {
            Logger().error("Error saving image: \(error)")
            return nil
        }
    }
    
    static func loadImageFromDisk(_ fileName: String) -> UIImage? {
        let fileURL = getDocumentsDir().appendingPathComponent(fileName)
        
        // Check whether the file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            Logger().error("File does not exist at path: \(fileURL.path)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            if data.isEmpty {
                Logger().error("Data is empty at path: \(fileURL.path)")
                return nil
            }
            
            if let image = UIImage(data: data) {
                return image
            } else {
                Logger().error("Failed to create UIImage from data at path: \(fileURL.path)")
                return nil
            }
        } catch {
            Logger().error("Error loading data from path: \(fileURL.path) - \(error)")
            return nil
        }
    }
}
