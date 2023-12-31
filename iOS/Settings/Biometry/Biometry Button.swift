import SwiftUI

struct BiometryButton: View {
    @Environment(SettingsVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        Toggle(isOn: $settings.useBiometry) {
            HStack(alignment: .bottom) {
                Text(vm.bioType == "Unknown" ? "Biometry unavailable" : vm.bioType)
                
                Button {
                    vm.sheetBio = true
                } label: {
                    Text("Learn more...")
                        .footnote()
                        .foregroundStyle(.teal)
                }
            }
        }
        .disabled(vm.bioType == "Unknown")
        .foregroundColor(vm.bioType == "Unknown" ? .gray : .none)
    }
}
