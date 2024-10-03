import Contacts
import PteroNet

#if canImport(ContactProvider)
import ContactProvider
#endif

extension OtherSettings {
    func enableExtension() {
        if #available(iOS 18, *) {
            do {
                let manager = try ContactProviderManager()
                
                Task {
                    try await manager.enable()
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
#warning("Present an alert")
        }
    }
}

extension ServerListVM {
    func saveContacts(_ users: [UserAttributes]) async {
        if #available(iOS 18, *) {
            do {
                let manager = try ContactProviderManager()
                
                Task {
                    try await manager.enable()
                }
                
                try await addContacts(users)
//                let manager = try ContactProviderManager()
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
                try await manager.disable()
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
        
        guard let id = bisqContainer?.identifier else {
            return
        }
        
        let existingContacts = try store.unifiedContacts(matching: CNContact.predicateForContactsInContainer(withIdentifier: id), keysToFetch: [CNContactEmailAddressesKey as CNKeyDescriptor])
        
        for user in users {
            let contact = CNMutableContact()
            contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: user.email as NSString)]
            
            // Check if a contact with the same email already exists
            if let _ = existingContacts.first(where: {
                guard let email = $0.emailAddresses.first?.value as String? else {
                    return false
                }
                
                return email == user.email
            }) {
                continue
            }
            
            saveRequest.add(contact, toContainerWithIdentifier: id)
        }
        
        try store.execute(saveRequest)
    }
}
