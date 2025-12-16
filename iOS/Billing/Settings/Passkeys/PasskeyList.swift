import SwiftUI

struct PasskeyList: View {
    @State private var vm = PasskeyListVM()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RegisterPasskeySection()
                
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
    }
}

#Preview {
    NavigationStack {
        PasskeyList()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
