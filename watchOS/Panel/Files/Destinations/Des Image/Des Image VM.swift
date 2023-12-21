import ScrechKit
import Kingfisher
import PteroNet

@Observable
final class ImageFileVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var cachedImage: UIImage? = nil
    var url = ""
    
    func downloadImage(_ path: String) {
        downloadFileAPI(id, from: path) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes.url {
                    self.url = model
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func loadCachedImage(_ path: String) {
        KingfisherManager.shared.cache.retrieveImage(forKey: path) { result in
            switch result {
            case .success(let imageResult):
                self.cachedImage = imageResult.image
                
            case .failure:
                break
            }
        }
    }
}
