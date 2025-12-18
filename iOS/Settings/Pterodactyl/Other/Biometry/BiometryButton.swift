import SwiftUI

struct BiometryButton: View {
    @State private var vm = BiometryVM()
    @EnvironmentObject private var store: ValueStore
    
    private var icon: String {
        switch vm.biometryType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        default: "exclamationmark.triangle"
        }
    }
    
    private var isAvailable: Bool {
        vm.biometryType != .none
    }
    
    var body: some View {
        GlassyToggle(vm.bioType, subtitle: "Confirm purchases & destructive actions", icon: icon, tint: isAvailable ? .blue : .red, isOn: $store.useBiometry)
            .disabled(!isAvailable)
            .opacity(isAvailable ? 1 : 0.3)
            .foregroundColor(isAvailable ? .gray : .none)
            .task {
                vm.defineBiometryType()
            }
    }
}

#Preview {
    BiometryButton()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
