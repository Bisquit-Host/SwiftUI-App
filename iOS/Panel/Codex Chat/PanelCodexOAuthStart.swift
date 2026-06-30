import Foundation
import Calagopus

struct PanelCodexOAuthStart {
    let verificationURL: URL
    let userCode: String
    
    init?(_ json: CalagopusJSON) {
        let object = json.objectValue ?? [:]
        
        guard
            let urlString = object["verificationUrl"]?.stringValue,
            let url = URL(string: urlString)
        else {
            return nil
        }
        
        verificationURL = url
        userCode = object["userCode"]?.stringValue ?? ""
    }
}
