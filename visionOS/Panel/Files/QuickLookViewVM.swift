import Foundation
import PteroNet

@Observable
final class QuickLookViewVM {
    var fileURL: URL? = nil
    
    func fetchDownloadURL(_ id: String?, file: String, at root: String?) async {
        guard let id, let root else { return }
        
        do {
            let url = try await fileDownloadAPI(id, path: root + "/" + file)
            fileURL = await downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
}
