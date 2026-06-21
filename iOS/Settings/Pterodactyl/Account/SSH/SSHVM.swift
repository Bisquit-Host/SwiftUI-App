import SwiftUI
import Calagopus

@Observable
final class SSHVM {
    private(set) var keys: [SSHKey] = []
    var newName = ""
    var newPublicKey = ""
    
    func fetchKeys() async {
        do {
            keys = try await sshListAPI()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createKey(onSuccess: @escaping () -> ()) async {
        do {
            let model = try await sshCreateAPI(newName, publicKey: newPublicKey)
            
            withAnimation {
                self.keys.append(model)
            }
            
            onSuccess()
            await fetchKeys()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteKey(_ fingerprint: String) async {
        do {
            try await sshDeleteAPI(fingerprint)
            
            if let index = self.keys.firstIndex(where: { $0.fingerprint == fingerprint }) {
                self.keys.remove(at: index)
            } else {
                await fetchKeys()
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func handleDrop(_ providers: [NSItemProvider]) {
        let type = "public.text"
        
        for provider in providers {
            if let name = provider.suggestedName {
                self.newName = name
            }
            
            if provider.hasItemConformingToTypeIdentifier(type) {
                provider.loadDataRepresentation(forTypeIdentifier: type) { data, _ in
                    if let data, let fileContent = String(data: data, encoding: .utf8) {
                        Task { @MainActor in
                            self.newPublicKey = fileContent
                        }
                    }
                }
            }
        }
    }
}
