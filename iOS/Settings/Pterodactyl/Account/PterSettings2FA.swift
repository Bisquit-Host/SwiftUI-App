import ScrechKit

struct PterSettings2FA: View {
    @Environment(AccountVM.self) private var vm
    
    @State private var sheetDisable2Fa = false
    @State private var sheetEnable2Fa = false
    
    var body: some View {
        List {            
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
        .sheet($sheetEnable2Fa) {
            NavigationStack {
                Enable2FAView()
            }
        }
        .sheet($sheetDisable2Fa) {
            Disable2FaView()
        }
    }    
}

#Preview {
    PterSettings2FA()
        .darkSchemePreferred()
        .environment(AccountVM())
}
