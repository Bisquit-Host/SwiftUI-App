import ScrechKit
import ContactsUI
import OSLog

struct ContactsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selectedEmail: String
    
    init(_ selectedEmail: Binding<String>) {
        _selectedEmail = selectedEmail
    }
    
    @State private var contacts: [CNContact] = []
    @State private var searchField = ""
    @State private var showPicker = false
    
    private var filteredContacts: [CNContact] {
        if searchField.isEmpty {
            contacts
        } else {
            contacts.filter { contact in
                return contact.emailAddresses.contains(where: { $0.value.localizedStandardContains(searchField) }) ||
                contact.givenName.localizedStandardContains(searchField) ||
                contact.familyName.localizedStandardContains(searchField)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredContacts, id: \.identifier) { contact in
                    Section(contact.fullName) {
                        ForEach(contact.emailAddresses, id: \.self) { email in
                            let email = email.value as String
                            
                            Button(email) {
                                selectedEmail = email
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchField)
            .contactAccessPicker($showPicker)
        }
        .task {
            loadContactsWithEmail()
        }
    }
    
    private func fetchContacts(_ identifiers: [String]) async -> [CNContact] {
        let store = CNContactStore()
        
        let keysToFetch = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
        
        var contacts = [CNContact]()
        
        do {
            try store.enumerateContacts(with: fetchRequest) { contact, _ in
                contacts.append(contact)
            }
        } catch {
            Logger().error("Failed to fetch contacts: \(error)")
        }
        
        return contacts
    }
    
    private func loadContactsWithEmail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let req = CNContactFetchRequest(keysToFetch: keys)
            
            do {
                var contactsWithEmail = [CNContact]()
                
                try store.enumerateContacts(with: req) { contact, _ in
                    if !contact.emailAddresses.isEmpty {
                        contactsWithEmail.append(contact)
                    }
                }
                
                Task { @MainActor in
                    self.contacts = contactsWithEmail
                }
            } catch {
                Logger().error("Failed to fetch contacts: \(error)")
            }
        }
    }
}

fileprivate extension CNContact {
    var fullName: String {
        [givenName, familyName].filter {
            !$0.isEmpty
        }.joined(separator: " ")
    }
}

#Preview {
    @Previewable @State var selectedEmail = "test@example.com"
    
    ContactsListView($selectedEmail)
        .darkSchemePreferred()
}
