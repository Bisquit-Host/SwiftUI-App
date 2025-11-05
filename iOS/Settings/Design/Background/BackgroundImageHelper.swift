import SwiftUI

final class BackgroundImageHelper {
    static func getDocumentsDir() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.heicData() else {
            print("Could not get HEIC data from image")
            return nil
        }
        
        let fileName = UUID().uuidString + ".heic"
        let fileURL = getDocumentsDir().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("Image saved at:", fileURL.path)
            
            // Return only the file name
            return fileName
        } catch {
            print("Error saving image:", error)
            return nil
        }
    }
    
    static func loadImageFromDisk(_ fileName: String) -> UIImage? {
        let fileURL = getDocumentsDir().appendingPathComponent(fileName)
        
        // Check whether the file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File does not exist at path:", fileURL.path)
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            if data.isEmpty {
                print("Data is empty at path:", fileURL.path)
                return nil
            }
            
            if let image = UIImage(data: data) {
                return image
            } else {
                print("Failed to create UIImage from data at path:", fileURL.path)
                return nil
            }
        } catch {
            print("Error loading data from path: \(fileURL.path) - \(error)")
            return nil
        }
    }
}
