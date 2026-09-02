import Foundation
import OSLog

enum RemoveSavedBackgroundImagesMigration {
    private static let backgroundFileNameKey = "background_image_fileName"

    static func run() {
        UserDefaults.standard.removeObject(forKey: backgroundFileNameKey)

        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: .documentsDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            let backgroundImageURLs = urls.filter(isSavedBackground)
            var removedImageCount = 0

            for url in backgroundImageURLs {
                do {
                    try FileManager.default.removeItem(at: url)
                    removedImageCount += 1
                } catch {
                    Logger().error("Could not remove saved background image \(url.lastPathComponent): \(error)")
                }
            }

            Logger().info("Removed \(removedImageCount) saved background images")
        } catch {
            Logger().error("Could not enumerate saved background images: \(error)")
        }
    }

    private static func isSavedBackground(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "heic" else {
            return false
        }

        return UUID(uuidString: url.deletingPathExtension().lastPathComponent) != nil
    }
}
