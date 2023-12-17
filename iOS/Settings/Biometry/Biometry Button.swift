import SwiftUI

struct BiometryButton: View {
    @Environment(SettingsVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        HStack {
            Toggle(isOn: $settings.useBiometry) {
                HStack(alignment: .bottom) {
                    Text(vm.bioType == "Unknown" ? "Biometry unavailable" : vm.bioType)
                    
                    Text("Learn more...")
                        .footnote()
                        .foregroundStyle(.teal)
                        .onTapGesture {
                            vm.sheetBio = true
                        }
                }
            }
            .disabled(vm.bioType == "Unknown")
            .foregroundColor(vm.bioType == "Unknown" ? .gray : .none)
        }
    }
}
