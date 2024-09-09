import ScrechKit

struct AccountView: View {
    @State private var vm = AccountVM()
    @State private var sshVM = SSHVM()
    
    @State private var sheetDisable2Fa = false
    @State private var sheetEnable2Fa = false
    
    var body: some View {
        List {
            if let account = vm.account {
                param("First name", value: account.firstName)
                
                param("Last name", value: account.lastName)
                
                param("E-mail", value: account.email)
            }
            
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
            
            Section("SSH Keys") {
                SSHList()
                    .environment(sshVM)
            }
        }
        .navigationTitle("Account")
        .toolbarTitleDisplayMode(.inline)
        .refreshableTask {
            vm.fetch()
            vm.twoFaDetails()
            sshVM.fetchKeys()
        }
        .sheet($sheetDisable2Fa) {
            Disable2FaView()
                .environment(vm)
        }
        .sheet($sheetEnable2Fa) {
            Enable2FAView()
                .environment(vm)
        }
    }
    
    private func param(_ param: String, value: String) -> some View {
        HStack {
            Text(param)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
        }
    }
}

#Preview {
    AccountView()
}
