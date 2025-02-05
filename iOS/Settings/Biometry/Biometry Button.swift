import SwiftUI

struct BiometryButton: View {
    @Environment(SettingsVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Toggle(isOn: $store.useBiometry) {
            Text(vm.bioType == "Unknown" ? "Biometry unavailable" : vm.bioType)
            
            Button("Learn more...") {
                vm.sheetBio = true
            }
            .foregroundStyle(.teal)
        }
        .disabled(vm.bioType == "Unknown")
        .foregroundColor(vm.bioType == "Unknown" ? .gray : .none)
    }
}
