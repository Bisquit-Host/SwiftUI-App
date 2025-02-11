import Contacts

@Observable
final class ContactManager {
    private let store = CNContactStore()
    
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
            print("Failed to save the contact:", error)
        }
    }
}
