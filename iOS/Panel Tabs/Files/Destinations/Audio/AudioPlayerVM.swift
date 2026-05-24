import Foundation
import PteroNet

@Observable
final class AudioPlayerVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var audioURL: URL? = nil
    
    func fetchDownloadURL(_ file: String, at path: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: path + "/" + file)
            audioURL = await downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
}
