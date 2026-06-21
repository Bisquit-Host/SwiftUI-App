import Calagopus

#if canImport(ContactProvider)
import Contacts
import ContactProvider
#endif

extension ServerListVM {
    func saveContacts(_ users: [UserAttributes]) async {
#if canImport(ContactProvider)
        do {
            let manager = try ContactProviderManager()
            
            try await addContacts(users)
            
            try await manager.signalEnumerator()
        } catch {
            Logger().error("Failed to add contact: \(error)")
        }
#else
        _ = users
#endif
    }
    
    func disable() async {
#if canImport(ContactProvider)
        do {
            let manager = try ContactProviderManager()
            try await manager.disable()
        } catch {
            Logger().error("Failed to disable: \(error)")
        }
#endif
    }
    
#if canImport(ContactProvider)
    private func addContacts(_ users: [UserAttributes]) async throws {
        let store = CNContactStore()
        
        let containers = try store.containers(matching: nil)
        
        let bisqContainer = containers.first {
#if DEBUG
            $0.name == "Bisquit.debug"
#else
            $0.name == "Bisquit.Host"
#endif
        }
        
        let saveRequest = CNSaveRequest()
        
        guard let id = bisqContainer?.identifier else {
            return
        }
        
        let existingContacts = try store.unifiedContacts(
            matching: CNContact.predicateForContactsInContainer(withIdentifier: id),
            keysToFetch: [
                CNContactEmailAddressesKey as CNKeyDescriptor
            ]
        )
        
        for user in users {
            let contact = CNMutableContact()
            
            contact.emailAddresses = [
                CNLabeledValue(
                    label: CNLabelHome,
                    value: user.email as NSString
                )
            ]
            
            // Check if a contact with the same email already exists
            if let _ = existingContacts.first(where: {
                guard
                    let email = $0.emailAddresses.first?.value as String?
                else {
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
#endif
}
