import SwiftUI

struct RegisterPasskeySection: View {
    @Environment(PasskeyListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
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
    }
}

#Preview {
    RegisterPasskeySection()
        .darkSchemePreferred()
}
