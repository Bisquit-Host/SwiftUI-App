import SwiftUI
import PteroNet

@Observable
final class SSHVM {
    var keys: [SSHKey] = []
    
    func fetchKeys() {
        sshListAPI { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.keys = model.map {
                            $0.attributes
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createKey(_ name: String, publicKey: String, onSuccess: @escaping () -> ()) {
        sshCreateAPI(name, publicKey: publicKey, printResponse: true) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    withAnimation {
                        self.keys.append(model)
                    }
                    
                    onSuccess()
                } else {
                    self.fetchKeys()
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteKey(_ fingerprint: String) {
        sshDeleteAPI(fingerprint, printResponse: true) { result in
            switch result {
            case .success:
                if let index = self.keys.firstIndex(where: {
                    $0.fingerprint == fingerprint
                }) {
                    self.keys.remove(at: index)
                } else {
                    self.fetchKeys()
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
