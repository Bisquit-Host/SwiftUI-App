import SwiftUI

struct ProtectionProfileEditorPresetSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @Binding private var presetId: Int
    private let selectedProtocolPresets: [VDSProtectionPreset]
    
    init(_ presetId: Binding<Int>, selectedProtocolPresets: [VDSProtectionPreset]) {
        _presetId = presetId
        self.selectedProtocolPresets = selectedProtocolPresets
    }
    
    var body: some View {
        VDSSectionCard("Preset") {
            if vm.presets.isEmpty {
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("No presets available")
                        .footnote()
                        .secondary()
                }
            } else {
                ProtectionPresetPicker($presetId, selectedProtocolPresets: selectedProtocolPresets)
            }
        }
    }
}
