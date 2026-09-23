import ScrechKit

struct ContactsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selectedEmail: String
    
    init(_ selectedEmail: Binding<String>) {
        _selectedEmail = selectedEmail
    }
    
    @State private var vm = ContactsListVM()
    @State private var showPicker = false

    var body: some View {
        @Bindable var vm = vm

        List {
            ForEach(vm.filteredContacts) { contact in
                Section(contact.fullName) {
                    ForEach(contact.emailAddresses, id: \.self) { email in
                        Button(email) {
                            selectedEmail = email
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Contacts")
        .searchable(text: $vm.searchField)
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        }
        .contactAccessPicker($showPicker)
        .task {
            await vm.loadContactsWithEmail()
        }
    }
}

#Preview {
    @Previewable @State var selectedEmail = "test@example.com"
    
    ContactsListView($selectedEmail)
        .darkSchemePreferred()
}
