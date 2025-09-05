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
    
    var body: some View {
        Toggle(isOn: $store.useBiometry) {
            Label(
                vm.biometryType == .none ? "Biometry unavailable" : vm.bioType,
                systemImage: icon
            )
            
            if vm.biometryType != .none {
                Button("Learn more...") {
                    vm.sheetBio = true
                }
                .footnote()
                .foregroundStyle(.blue.secondary)
            }
        }
        .disabled(vm.bioType == "Unknown")
        .foregroundColor(vm.bioType == "Unknown" ? .gray : .none)
        .task {
            vm.defineBiometryType()
        }
        .sheet($vm.sheetBio) {
            BiometryUsageView()
        }
    }
}

#Preview {
    BiometryButton()
        .environmentObject(ValueStore())
}
