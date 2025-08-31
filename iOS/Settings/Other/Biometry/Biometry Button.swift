import SwiftUI

struct BiometryButton: View {
    @Environment(BiometryVM.self) private var vm
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
                vm.bioType == "Unknown" ? "Biometry unavailable" : vm.bioType,
                systemImage: icon
            )
            
            Button("Learn more...") {
                vm.sheetBio = true
            }
            .footnote()
            .foregroundStyle(.blue.secondary)
        }
        .disabled(vm.bioType == "Unknown")
        .foregroundColor(vm.bioType == "Unknown" ? .gray : .none)
    }
}
