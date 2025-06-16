import ScrechKit

struct AccountView: View {
    @Environment(AccountVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetDisable2Fa = false
    @State private var sheetEnable2Fa = false
    @State private var selectedTab = "Account"
    
    var body: some View {
        List {
            Section {
                if let account = vm.account {
                    let name = "\(account.firstName) \(account.lastName)"
                    
                    param("Name", value: name)
                    param("E-mail", value: account.email)
                }
            }
            
            CredentialsButton()
            
            Section("2FA") {
                if vm.twoFaEnabled {
                    Menu {
                        Button(role: .destructive) {
                            sheetDisable2Fa = true
                        } label: {
                            Label("Disable 2FA", systemImage: "xmark.circle")
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
                    ListButton("Setup 2FA", actionIcon: "key.viewfinder") {
                        sheetEnable2Fa = true
                    }
                    
                    //                    Menu {
                    //                        MenuButton("Copy URL", icon: "doc.on.doc") {
                    //                            UIPasteboard.general.string = vm.qrCodeUrl
                    //                            SystemAlert.copied()
                    //                        }
                    //
                    //                        if let url = URL(string: vm.qrCodeUrl) {
                    //                            Link(destination: url) {
                    //                                Label("Open URL", systemImage: "link")
                    //                            }
                    //                        }
                    //
                    //                        MenuButton("View QR code", icon: "qrcode") {
                    //                            sheetQrCode = true
                    //                        }
                    //                    } label: {
                    //                        ListButton("Setup 2FA", actionIcon: "key.viewfinder")
                    //                    }
                }
            }
        }
        .navigationTitle("Account")
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
            Enable2FAView()
        }
        .sheet($sheetDisable2Fa) {
            Disable2FaView()
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
        }
    }
    
    private func param(_ param: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(param)
                .secondary()
            
            Spacer()
            
            Text(value)
        }
    }
}

#Preview {
    AccountView()
        .environment(AccountVM())
}
