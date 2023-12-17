import ScrechKit

struct AccountView: View {
    private var vm = AccountVM()
    
    @State private var sheetCode = false
    
    var body: some View {
        List {
            if let account = vm.account {
                param("First name", value: account.first_name)
                
                param("Last name", value: account.last_name)
                
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
        }
        .navigationTitle("Account")
        .toolbarTitleDisplayMode(.inline)
        .task {
            vm.fetch()
            vm.twoFaDetails()
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
