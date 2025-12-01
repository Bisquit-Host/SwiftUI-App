import SwiftUI

struct BillingPasskeysView: View {
    @State private var vm = BillingPasskeysVM()
    
    var body: some View {
        List {
            Section("Register new passkey") {
                TextField("Label (optional)", text: $vm.label)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                Button {
                    Task { await vm.registerPasskey() }
                } label: {
                    if vm.isRegistering {
                        HStack {
                            ProgressView()
                            Text("Creating passkey...")
                        }
                    } else {
                        Text("Create passkey")
                    }
                }
                .disabled(vm.isRegistering)
            }
            
            Section("Your passkeys") {
                if vm.passkeys.isEmpty && !vm.isLoading {
                    ContentUnavailableView("No passkeys yet", systemImage: "key.fill", description: Text("Register a passkey to sign in without a password."))
                        .listRowBackground(Color.clear)
                }
                
                ForEach(vm.passkeys) { passkey in
                    BillingPasskeyRow(passkey)
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                Task { await vm.deletePasskey(passkey) }
                            }
                        }
                }
            }
        }
        .navigationTitle("Passkeys")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await vm.fetchPasskeys()
        }
        .task {
            await vm.fetchPasskeys()
        }
        .overlay {
            if vm.isLoading {
                ProgressView("Loading passkeys...")
            }
        }
        .alert("Passkey error", isPresented: Binding(get: {
            vm.error != nil
        }, set: { newValue in
            if !newValue {
                vm.error = nil
            }
        })) {
            Button("OK", role: .cancel) {
                vm.error = nil
            }
        } message: {
            if let error = vm.error {
                Text(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BillingPasskeysView()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
