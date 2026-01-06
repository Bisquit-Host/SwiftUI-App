import ScrechKit

struct PasskeyList: View {
    @Environment(PasskeyListVM.self) private var vm
    
    @State private var alertCreate = false
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            VStack(spacing: 10) {
                ForEach(vm.passkeys) {
                    PasskeyCard($0)
                }
                .animation(.default, value: vm.passkeys)
            }
            .scenePadding()
        }
        .navigationTitle("Passkeys")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .refreshableTask {
            await vm.fetchPasskeys()
        }
        .background {
            LinearGradient(colors: [.blue.opacity(0.08), Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
        .toolbar {
            SFButton("plus") {
                alertCreate = true
            }
        }
        .alert("Create Passkey", isPresented: $alertCreate) {
            TextField("Label (optional)", text: $vm.label)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            Button("Create", role: .confirm, action: create)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func create() {
        Task {
            await vm.registerPasskey()
        }
    }
}

#Preview {
    NavigationStack {
        PasskeyList()
    }
    .environmentObject(ValueStore())
    .environment(PasskeyListVM())
    .darkSchemePreferred()
}
