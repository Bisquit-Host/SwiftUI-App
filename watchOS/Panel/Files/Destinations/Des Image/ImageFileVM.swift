import SwiftUI
import Kingfisher
import Calagopus

@Observable
final class ImageFileVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var cachedImage: UIImage? = nil
    var url = ""
    
    func downloadImage(_ path: String) async {
        do {
            url = try await CalagopusNet.client().fileDownloadURL(server: id, path: path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func loadCachedImage(_ path: String) {
        KingfisherManager.shared.cache.retrieveImage(forKey: path) { result in
            switch result {
            case .success(let imageResult):
                Task { @MainActor in
                    self.cachedImage = imageResult.image
                }
                
            case .failure:
                break
            }
        }
    }
}
