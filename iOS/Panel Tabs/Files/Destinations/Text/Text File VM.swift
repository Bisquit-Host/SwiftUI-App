import ScrechKit
import PteroNet

@Observable
final class TextFileVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var text = ""
    var initialText = ""
    var showPrettyButton = false
    
    func makePretty() {
        if let pretty = ScrechKit.prettyJSON(text) {
            text = pretty
            showPrettyButton = false
        }
    }
    
    func writeFile(_ write: String, path: String) {
        fileWriteAPI(id, write: write, path: path) { result in
            switch result {
            case .success(let model):
                SystemAlert.changesSaved()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func getFileContents(_ path: String) {
        fileContentsAPI(id, path: path) { result in
            switch result {
            case .success(let model):
                main {
                    self.text = model
                    self.initialText = model
                    self.checkPrettiness()
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func checkPrettiness() {
        if let pretty = ScrechKit.prettyJSON(text), pretty != text {
            showPrettyButton = true
        }
    }
}
