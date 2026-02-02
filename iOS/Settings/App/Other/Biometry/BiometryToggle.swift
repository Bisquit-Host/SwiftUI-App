import SwiftUI

struct BiometryToggle: View {
    @Environment(BiometryVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    @State private var isAuthenticating = false
    @State private var toggleValue = false
    
    private var isAvailable: Bool {
        vm.biometryType != .none
    }
    
    var body: some View {
        GlassyToggle(vm.bioType ?? "Biometry unavailable", subtitle: "Confirm purchases & destructive actions", icon: vm.icon, tint: store.useBiometry ? .blue : .red, isOn: $toggleValue)
            .disabled(!isAvailable || isAuthenticating)
            .opacity(isAvailable ? 1 : 0.3)
            .task {
                toggleValue = store.useBiometry
            }
            .onChange(of: store.useBiometry) { _, newValue in
                if toggleValue != newValue {
                    toggleValue = newValue
                }
            }
            .onChange(of: toggleValue) { _, newValue in
                if newValue {
                    store.useBiometry = true
                    return
                }
                
                guard store.useBiometry, !isAuthenticating else {
                    return
                }
                
                isAuthenticating = true
                
                Task {
                    let label: String = {
                        switch vm.biometryType {
                        case .faceID: return "Face ID"
                        case .touchID: return "Touch ID"
                        case .opticID: return "Optic ID"
                        default: return "biometry"
                        }
                    }()
                    let ok = await vm.authenticate("Confirm to disable \(label)")
                    
                    await MainActor.run {
                        if ok {
                            store.useBiometry = false
                        } else {
                            toggleValue = true
                        }
                        
                        isAuthenticating = false
                    }
                }
            }
    }
}

#Preview {
    BiometryToggle()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
