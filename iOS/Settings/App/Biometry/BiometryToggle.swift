import SwiftUI

struct BiometryToggle: View {
    @Environment(BiometryVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private var isAvailable: Bool {
        vm.biometryType != .none
    }
    
    var body: some View {
        GlassyToggle(vm.bioType ?? "Biometry unsavailable", subtitle: "Confirm purchases & destructive actions", icon: vm.icon, tint: store.useBiometry ? .blue : .red, isOn: $store.useBiometry)
            .disabled(!isAvailable)
            .opacity(isAvailable ? 1 : 0.3)
            .foregroundColor(isAvailable ? .gray : .none)
    }
}

#Preview {
    BiometryToggle()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
