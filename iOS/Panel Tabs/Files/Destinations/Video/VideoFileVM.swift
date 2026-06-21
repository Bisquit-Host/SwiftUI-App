import SwiftUI
import Calagopus

@Observable
final class VideoFileVM {
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
    }
    
    var isSensitive = false
    var localVideoURL: URL?
    
    func fetchVideoURL(_ name: String, root: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: root + "/" + name)
            
            guard let fileURL = await downloadFile(url, name: name) else {
                return
            }

            await loadAndCheckVideo(fileURL)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func loadAndCheckVideo(_ fileURL: URL) async {
#if !os(watchOS) && !os(tvOS)
        await SensitivityAnalyzer().checkVideo(fileURL) { blur in
            self.isSensitive = blur

            withAnimation {
                self.localVideoURL = fileURL
            }
        }
#else
        localVideoURL = fileURL
#endif
    }
}
