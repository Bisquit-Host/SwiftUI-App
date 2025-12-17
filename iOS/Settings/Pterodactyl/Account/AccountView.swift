import ScrechKit

struct AccountView: View {
    @Environment(AccountVM.self) private var vm
    
    @State private var sheetDisable2Fa = false
    @State private var sheetEnable2Fa = false
    
    var body: some View {
        List {
            Section {
                if let account = vm.account {
                    let name = account.firstName + " " + account.lastName
#if DEBUG
                    param("ID", value: account.id.description)
#endif
                    param("Name", value: name)
                    param("Email", value: account.email)
                }
            }
            
            CredentialsButton()
            
            if let twoFaEnabled = vm.twoFaEnabled {
                Section("2FA") {
                    if twoFaEnabled {
                        Menu {
                            Button("Disable 2FA", systemImage: "xmark.circle", role: .destructive) {
                                sheetDisable2Fa = true
                            }
                        } label: {
                            HStack {
                                Text("2FA enabled")
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(.green)
                            }
                        }
                        .foregroundStyle(.foreground)
                    } else {
                        ListButton("Setup 2FA", actionIcon: "exclamationmark.triangle.fill") {
                            sheetEnable2Fa = true
                        }
                    }
                }
            }
        }
        .navigationTitle("Account")
        .scrollContentBackground(.hidden)
        .refreshableTask {
            let fetchTask = Task {
                await vm.fetch()
            }
            
            let twoFaTask = Task {
                await vm.twoFaDetails()
            }
            
            await fetchTask.value
            await twoFaTask.value
        }
        .sheet($sheetEnable2Fa) {
            NavigationStack {
                Enable2FAView()
            }
        }
        .sheet($sheetDisable2Fa) {
            Disable2FaView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
        }
    }
    
    private func param(_ param: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(param)
            
            Spacer()
            
            Text(value)
                .secondary()
        }
    }
}

#Preview {
    AccountView()
        .darkSchemePreferred()
        .environment(AccountVM())
}
