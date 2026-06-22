import SwiftUI
import Calagopus

@Observable
final class SSHVM {
    private(set) var keys: [CalagopusSSHKey] = []
    var newName = ""
    var newPublicKey = ""
    
    func fetchKeys() async {
        do {
            keys = try await CalagopusClientFactory.client().sshKeys().data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createKey(onSuccess: @escaping () -> ()) async {
        do {
            let model = try await CalagopusClientFactory.client().createSSHKey(name: newName, publicKey: newPublicKey)
            
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
            guard let key = keys.first(where: { $0.fingerprint == fingerprint }), let id = key.uuid else {
                await fetchKeys()
                return
            }
            
            try await CalagopusClientFactory.client().deleteSSHKey(id: id)
            
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
