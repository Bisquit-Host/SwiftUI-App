import ContactProvider
import Contacts
import PteroNet

extension ServerListVM {
    func enableExtensionExample() async {
        if #available(iOS 18, *) {
            do {
                // Creates contact provider manager with a default domain
                let manager = try ContactProviderManager()
                
                // May prompt to enable the default domain
                try await manager.enable()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveContacts(_ users: [UserAttributes]) async {
        if #available(iOS 18, *) {
            do {
                try await addContacts(users)
                let manager = try ContactProviderManager()
                try await manager.signalEnumerator()
            } catch {
                print("Failed to add contact: \(error.localizedDescription)")
            }
        }
    }
    
    func disable() async {
        if #available(iOS 18, *) {
            do {
                let manager = try ContactProviderManager()
                try manager.disable()
            } catch {
                print("Failed to disable: \(error.localizedDescription)")
            }
        }
    }
    
    private func addContacts(_ users: [UserAttributes]) async throws {
        let store = CNContactStore()
        
        let containers = try store.containers(matching: nil)
        
        let bisqContainer = containers.first { container in
#if DEBUG
            container.name == "Bisquit.debug"
#else
            container.name == "Bisquit.Host"
#endif
        }
        
        let saveRequest = CNSaveRequest()
        let id = bisqContainer?.identifier
        
        for user in users {
            let contact = CNMutableContact()
            contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: user.email as NSString)]
            saveRequest.add(contact, toContainerWithIdentifier: id)
        }
        
        try store.execute(saveRequest)
    }
}
