import ScrechKit

struct AccountView: View {
    @State private var vm = AccountVM()
    @State private var sshVM = SSHVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetDisable2Fa = false
    @State private var sheetEnable2Fa = false
    
    var body: some View {
        List {
            Section {
                if let account = vm.account {
                    param("First name", value: account.firstName)
                    
                    param("Last name", value: account.lastName)
                    
                    param("E-mail", value: account.email)
                }
            }
            .listRowBackground(store.transparentList ? .clear : Color.list)
            
            AccountSettings()
            
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
            .listRowBackground(store.transparentList ? .clear : Color.list)
            
            Section("SSH Keys") {
                SSHList()
                    .environment(sshVM)
            }
            .listRowBackground(store.transparentList ? .clear : Color.list)
        }
        .navigationTitle("Account")
        .toolbarTitleDisplayMode(.inline)
        .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
        .refreshableTask {
            vm.fetch()
            vm.twoFaDetails()
            sshVM.fetchKeys()
        }
        .sheet($sheetDisable2Fa) {
            Disable2FaView()
        }
        .sheet($sheetEnable2Fa) {
            Enable2FAView()
        }
        .environment(vm)
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
}
