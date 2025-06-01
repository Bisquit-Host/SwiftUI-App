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
    
    func writeFile(_ write: String, at path: String) async {
        do {
            try await fileWriteAPI(id, write: write, path: path)
            SystemAlert.changesSaved()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func getFileContents(_ path: String) async {
        do {
            let model = try await fileContentsAPI(id, path: path)
            main {
                self.text = model
                self.initialText = model
                self.checkPrettiness()
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func checkPrettiness() {
        if let pretty = ScrechKit.prettyJSON(text), pretty != text {
            showPrettyButton = true
        }
    }
}
