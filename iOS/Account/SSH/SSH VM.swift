import ScrechKit
import PteroNet

@Observable
final class SSHVM {
    private(set) var keys: [SSHKey] = []
    var newName = ""
    var newPublicKey = ""
    
    func fetchKeys() {
        sshListAPI { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.keys = model.map(\.attributes)
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func createKey(onSuccess: @escaping () -> ()) {
        sshCreateAPI(newName, publicKey: newPublicKey, printResponse: true) { result in
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
                SystemAlert.error(error)
            }
        }
    }
    
    func deleteKey(_ fingerprint: String) {
        sshDeleteAPI(fingerprint) { result in
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
                SystemAlert.error(error)
            }
        }
    }
    
    func handleDrop(_ providers: [NSItemProvider]) {
        let type = "public.text"
        
        for provider in providers {
            if let name = provider.suggestedName {
                self.newName = name
            }
            
            if provider.hasItemConformingToTypeIdentifier(type) {
                provider.loadDataRepresentation(forTypeIdentifier: type) { data, error in
                    if let data, let fileContent = String(data: data, encoding: .utf8) {
                        self.newPublicKey = fileContent
                    }
                }
            }
        }
    }
}
