import ScrechKit
import PteroNet

@Observable
final class TextFileVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var text = ""
    
    func writeFile(_ write: String, path: String) {
        fileWriteAPI(id, write: write, path: path) { result in
            switch result {
            case .success(let model):
                print(model)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func getFileContents(_ path: String) {
        fileContentsAPI(id, path: path) { result in
            switch result {
            case .success(let model):
                main {
                    self.text = model
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
