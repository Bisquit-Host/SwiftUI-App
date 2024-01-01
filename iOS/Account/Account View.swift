import ScrechKit

struct AccountView: View {
    private var vm = AccountVM()
    private var sshVM = SSHVM()
    
    @State private var sheetCode = false
    
    var body: some View {
        List {
            if let account = vm.account {
                param("First name", value: account.firstName)
                
                param("Last name", value: account.lastName)
                
                param("E-mail", value: account.email)
            }
            
            Section("2FA") {
                Menu {
                    MenuButton("Copy", icon: "doc.on.doc") {
                        UIPasteboard.general.string = vm.qrCodeUrl
                        SystemAlert.copied()
                    }
                    
                    //                    Link(destination: URL(string: vm.qrCodeUrl)!) {
                    //                        Label("Open", systemImage: "link")
                    //                    }
                    
                    MenuButton("View QR code", icon: "qrcode") {
                        sheetCode = true
                    }
                } label: {
                    ListButton("Setup 2FA", actionIcon: "key.viewfinder")
                }
            }
            
            Section("SSH Keys") {
                SSHList()
                    .environment(sshVM)
            }
        }
        .navigationTitle("Account")
        .toolbarTitleDisplayMode(.inline)
        .task {
            vm.fetch()
            vm.twoFaDetails()
            sshVM.fetchKeys()
        }
        .sheet($sheetCode) {
            QRCodeView(vm.qrCodeUrl)
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
