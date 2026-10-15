import ScrechKit

struct DatabaseInstanceUserCreateSheet: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        Form {
            Section {
                TextField("Username", text: $vm.newUsername)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .limitInputLength($vm.newUsername, length: 23)
            } footer: {
                Text("2-23 letters or numbers")
            }
            
            if vm.instance.type != .redis {
                Section {
                    Picker("Database", selection: $vm.newUserDatabaseID) {
                        Text("All databases")
                            .tag(nil as String?)
                        
                        ForEach(vm.databases) {
                            Text($0.name)
                                .tag($0.id as String?)
                        }
                    }
                }
            }
        }
        .navigationTitle("New User")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    vm.newUsername = ""
                    vm.newUserDatabaseID = nil
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Create", systemImage: "checkmark", role: .confirm) {
                    let count = vm.users.count
                    await vm.createUser()
                    
                    if vm.users.count > count {
                        dismiss()
                    }
                }
                .disabled(vm.newUsername.count < 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseInstanceUserCreateSheet()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
