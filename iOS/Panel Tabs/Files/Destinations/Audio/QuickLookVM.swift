import Foundation
import Calagopus

@Observable
final class QuickLookVM {
    var fileURL: URL? = nil
    
    func fetchDownloadURL(_ id: String, file: String, at path: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: path + "/" + file)
            fileURL = await downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
}
