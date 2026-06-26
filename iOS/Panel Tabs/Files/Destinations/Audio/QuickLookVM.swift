import Foundation
import Calagopus
import OSLog

@Observable
final class QuickLookVM {
    var fileURL: URL? = nil
    
    func fetchDownloadURL(_ id: String, file: String, at path: String) async {
        do {
            let url = try await CalagopusNet.client().fileDownloadURL(server: id, path: path + "/" + file)
            fileURL = await FileShareCache.localFile(from: url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
}
