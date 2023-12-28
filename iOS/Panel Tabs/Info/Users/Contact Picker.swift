import ScrechKit
import Contacts

struct ContactsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selectedEmail: String
    
    init(_ selectedEmail: Binding<String>) {
        _selectedEmail = selectedEmail
    }
    
    @State private var contacts: [CNContact] = []
    @State private var searchField = ""
    
    private var filteredContacts: [CNContact] {
        if searchField.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                let searchLowercased = searchField.lowercased()
                
                return contact.emailAddresses.contains(where: { $0.value.lowercased.contains(searchLowercased) }) ||
                contact.givenName.lowercased().contains(searchLowercased) ||
                contact.familyName.lowercased().contains(searchLowercased)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredContacts, id: \.identifier) { contact in
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
            .navigationTitle("Contacts")
            .searchable(text: $searchField)
            .animation(.default, value: filteredContacts)
        }
        .onAppear {
            loadContactsWithEmail()
        }
    }
    
    private func loadContactsWithEmail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            do {
                var contactsWithEmail = [CNContact]()
                
                try store.enumerateContacts(with: request) { (contact, stop) in
                    if !contact.emailAddresses.isEmpty {
                        contactsWithEmail.append(contact)
                    }
                }

                main {
                    self.contacts = contactsWithEmail
                }
            } catch {
                main {
                    print("Failed to fetch contacts: \(error)")
                }
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
    ContactsListView(.constant(""))
}
