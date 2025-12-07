import SwiftUI

struct PasskeyList: View {
    @State private var vm = PasskeyListVM()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                BillingSectionCard("Register new Passkey") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Label (optional)", text: $vm.label)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(12)
                            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.primary.opacity(0.06), lineWidth: 1)
                            }
                        
                        Button {
                            Task {
                                await vm.registerPasskey()
                            }
                        } label: {
                            if vm.isRegistering {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(.white)
                                    
                                    Text("Creating passkey...")
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                Text("Create")
                                    .rounded()
                                    .semibold()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.blue)
                        .disabled(vm.isRegistering)
                    }
                }
                
                BillingSectionCard {
                    if vm.passkeys.isEmpty && !vm.isLoading {
                        ContentUnavailableView("No Passkeys yet", systemImage: "key.fill", description: Text("Register a Passkey to sign in without a password"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(vm.passkeys) {
                                PasskeyCard($0)
                            }
                            .animation(.default, value: vm.passkeys)
                        }
                    }
                }
            }
            .scenePadding()
        }
        .navigationTitle("Passkeys")
        .navigationBarTitleDisplayMode(.inline)
        .environment(vm)
        .scrollIndicators(.never)
        .background {
            LinearGradient(colors: [.blue.opacity(0.08), Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
        .refreshableTask {
            await vm.fetchPasskeys()
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
        PasskeyList()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
