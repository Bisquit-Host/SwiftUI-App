import SwiftUI
import BisquitoNet

struct ProtectionPresetPicker: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @Binding private var presetId: Int
    private let selectedProtocolPresets: [VDSProtectionPreset]
    
    init(_ presetId: Binding<Int>, selectedProtocolPresets: [VDSProtectionPreset]) {
        _presetId = presetId
        self.selectedProtocolPresets = selectedProtocolPresets
    }
    
    private var selectedPresetTitle: String {
        if let preset = vm.presets.first(where: { $0.id == presetId }) {
            "\(preset.name) • \(preset.`protocol`.rawValue)"
        } else {
            "Select preset"
        }
    }
    
    var body: some View {
        Picker(selection: $presetId) {
            ForEach(selectedProtocolPresets) {
                Text($0.name)
                    .tag($0.id)
            }
        } label: {
            HStack {
                Text(selectedPresetTitle)
                    .subheadline(.semibold)
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .secondary()
            }
        }
        .tint(.primary)
        .pickerStyle(.menu)
    }
}
