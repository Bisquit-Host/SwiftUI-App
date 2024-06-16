import ContactProvider
import Contacts

@Observable
final class ContactProvider {
    func enableExtensionExample() async {
        if #available(iOS 18, *) {
            do {
                // The app creates a contact provider manager with a default domain
                let manager = try ContactProviderManager()
                
                // May prompt the person to enable the default domain
                try await manager.enable()
                
                if manager.isEnabled {
                    print(manager.domain.displayName + ":" + manager.domain.identifier)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveNewContact() async {
        if #available(iOS 18, *) {
            do {
                try await addContact(givenName: "Pavel", familyName: "Pyzhh", email: "pyzh_pavel@icloud.com")
                
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
        
    private func addContact(givenName: String, familyName: String, email: String) async throws {
        let store = CNContactStore()
        
        let containers = try store.containers(matching: nil)
        
        let bisqContainer = containers.first { container in
#if DEBUG
            container.name == "Bisquit.debug"
#else
            container.name == "Bisquit.Host"
#endif
        }
        
        //        let id = "975E6A06-2FCE-48C2-9BB8-8476479BC91B:ABContainer"
        let id = bisqContainer?.identifier
        
        print(containers.map(\.identifier))
        print(containers.map(\.name))
//        print(containers.map(\.type.rawValue))
        
                
        let contact = CNMutableContact()
        contact.givenName = givenName
        contact.familyName = familyName
        contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: email as NSString)]
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: id)
        
        try store.execute(saveRequest)
    }
}
