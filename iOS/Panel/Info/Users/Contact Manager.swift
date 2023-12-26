import Contacts

@Observable
final class ContactManager {
    private let store = CNContactStore()
    
    func requestPermission() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            break
            
        case .denied, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if let error {
                    print("Error requesting permissions: \(error)")
                }
            }
            
        default:
            break
        }
    }
    
    func saveContact(_ email: String) {
        let newContact = CNMutableContact()
        
        let emailLabel = CNLabeledValue(label: CNLabelWork, value: email as NSString)
        newContact.emailAddresses = [emailLabel]
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
            print("Saved!")
        } catch let error {
            print("Failed to save the contact: \(error)")
        }
    }
}
