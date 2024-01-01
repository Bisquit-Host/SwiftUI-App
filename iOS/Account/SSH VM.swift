import Foundation
import PteroNet

@Observable
final class SSHVM {
    var keys: [SSHKey] = []
    
    func fetchKeys() {
        sshListAPI(printResponse: true) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    self.keys = model.map {
                        $0.attributes
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createKey(_ name: String, publicKey: String) {
        sshCreateAPI(name, publicKey: publicKey, printResponse: true) { result in
            switch result {
            case .success:
                self.fetchKeys()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteKey(_ footprint: String) {
        sshDeleteAPI(footprint, printResponse: true) { result in
            switch result {
            case .success:
                self.fetchKeys()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
