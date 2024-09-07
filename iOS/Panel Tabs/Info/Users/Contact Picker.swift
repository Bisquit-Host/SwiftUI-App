import ScrechKit
import ContactsUI

#warning("iOS 18")
//fileprivate struct ContactAccessPickerModifier: ViewModifier {
//    @Binding private var isPresented: Bool
//    
//    init(_ isPresented: Binding<Bool>) {
//        _isPresented = isPresented
//    }
//    
//    func body(content: Content) -> some View {
//        if #available(iOS 18, *) {
//#warning("Implement")
//            content
//                .contactAccessPicker(isPresented: $isPresented)// { identifiers in }
//                .toolbar {
//                    SFButton("person.crop.circle.badge.plus") {
//                        isPresented = true
//                    }
//                }
//        } else {
//            content
//        }
//    }
//}
//
//fileprivate extension View {
//    func contactAccessPicker(_ isPresented: Binding<Bool>) -> some View {
//        self.modifier(ContactAccessPickerModifier(isPresented))
//    }
//}

struct ContactsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selectedEmail: String
    
    init(_ selectedEmail: Binding<String>) {
        _selectedEmail = selectedEmail
    }
    
    @State private var contacts: [CNContact] = []
    @State private var moreContacts: [CNContact] = []
    @State private var searchField = ""
    @State private var authStatus: CNAuthorizationStatus = .notDetermined
#warning("iOS 18")
//    @State private var showPicker = false
    
    private var filteredContacts: [CNContact] {
        if searchField.isEmpty {
            contacts
        } else {
            contacts.filter { contact in
                let searchLowercased = searchField.lowercased()
                
                return contact.emailAddresses.contains(where: { $0.value.lowercased.contains(searchLowercased) }) ||
                contact.givenName.lowercased().contains(searchLowercased) ||
                contact.familyName.lowercased().contains(searchLowercased)
            }
        }
    }
    
    var body: some View {
        NavigationView {
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
                
                ForEach(moreContacts, id: \.identifier) { contact in
                    Text(contact.fullName)
                }
                .animation(.default, value: filteredContacts)
                
#warning("iOS 18")
                //                if #available(iOS 18, *) {
                //                    if authStatus == .limited || authStatus == .notDetermined {
                //                        Section {
                //                            ContactAccessButton(queryString: searchField) { identifiers in
                //                                handleFetchContacts(identifiers)
                //                            }
                //                        }
                //                    }
                //                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchField)
#warning("iOS 18")
//            .contactAccessPicker($showPicker)
        }
        .task {
            loadContactsWithEmail()
        }
    }
    
    private func handleFetchContacts(_ identifiers: [String]) {
        Task {
            let fetchedContacts = await fetchContacts(identifiers)
            
            DispatchQueue.main.async {
                self.moreContacts = fetchedContacts
            }
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
            try store.enumerateContacts(with: fetchRequest) { contact, stop in
                contacts.append(contact)
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
        
        return contacts
    }
    
    private func loadContactsWithEmail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            do {
                var contactsWithEmail = [CNContact]()
                
                try store.enumerateContacts(with: request) { contact, stop in
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
    @Previewable @State var selectedEmail = "test@example.com"

    ContactsListView($selectedEmail)
}
