import SwiftUI

struct ProtectionProfileEditor: View {
    @Environment(VDSProtectionVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let mode: CloudProtectionProfileEditorMode
    
    @State private var presetId = 0
    @State private var protocolSelection: VDSProtectionProtocol
    @State private var minPortText: String
    @State private var maxPortText: String
    @State private var notesText: String
    
    init(_ mode: CloudProtectionProfileEditorMode) {
        self.mode = mode
        let existing = mode.existingProfile
        
        _protocolSelection = State(initialValue: existing?.`protocol` ?? .tcp)
        _minPortText = State(initialValue: existing?.minDstPort.map(String.init) ?? "")
        _maxPortText = State(initialValue: existing?.maxDstPort.map(String.init) ?? "")
        _notesText = State(initialValue: existing?.notes ?? "")
    }
    
    private var selectedProtocolPresets: [VDSProtectionPreset] {
        vm.presets.filter {
            $0.`protocol` == protocolSelection
        }
    }
    
    var body: some View {
        ScrollView {
            ProtectionProfileEditorPresetSection($presetId, selectedProtocolPresets: selectedProtocolPresets)
            
            VDSSectionCard("Protocol") {
                Picker("Protocol", selection: $protocolSelection) {
                    ForEach(VDSProtectionProtocol.allCases) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                
                if protocolSelection == .tcp || protocolSelection == .udp {
                    HStack(spacing: 10) {
                        TextField("Min port (1–65535)", text: $minPortText)
                            .keyboardType(.numberPad)
                            .textInputAutocapitalization(.never)
                            .limitInputLength($minPortText, length: 5)
                        
                        TextField("Max port (1–65535)", text: $maxPortText)
                            .keyboardType(.numberPad)
                            .textInputAutocapitalization(.never)
                            .limitInputLength($maxPortText, length: 5)
                    }
                } else {
                    Text("Ports not applicable for \(protocolSelection.rawValue)")
                        .footnote()
                        .secondary()
                }
                
                TextField("Notes (optional)", text: $notesText, axis: .vertical)
                    .textInputAutocapitalization(.sentences)
            }
            
            Button(mode.actionTitle, action: save)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction || presetId == 0)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .onAppear {
            if vm.presets.contains(where: { $0.id == presetId }) {
                return
            }
            
            if let first = vm.presets.first {
                presetId = first.id
                protocolSelection = first.`protocol`
                applyDefaultPortsIfNeeded(for: first.`protocol`)
            }
        }
        .onChange(of: vm.presets) { _, newPresets in
            if newPresets.contains(where: { $0.id == presetId }) {
                return
            }
            
            if let first = newPresets.first {
                presetId = first.id
                protocolSelection = first.`protocol`
                applyDefaultPortsIfNeeded(for: first.`protocol`)
            }
        }
        .onChange(of: presetId) { _, newValue in
            if let preset = vm.presets.first(where: { $0.id == newValue }) {
                protocolSelection = preset.`protocol`
                applyDefaultPortsIfNeeded(for: preset.`protocol`)
            }
        }
        .onChange(of: protocolSelection) { _, newProto in
            presetId = selectedProtocolPresets.first?.id ?? 0
            
            if newProto == .tcp || newProto == .udp {
                applyDefaultPortsIfNeeded(for: newProto)
            } else {
                minPortText = ""
                maxPortText = ""
            }
        }
    }
    
    private func save() {
        Task {
            guard let input = makeInput() else { return }
            
            switch mode {
            case .create:
                await vm.createProfile(input)
                
            case .edit(let profile):
                await vm.updateProfile(profile.id, input: input)
            }
            
            dismiss()
        }
    }
    
    private func makeInput() -> VDSProtectionProfileInput? {
        var input = VDSProtectionProfileInput(presetId: presetId, protocol: protocolSelection, minPort: nil, maxPort: nil, notes: nil)
        
        if protocolSelection == .tcp || protocolSelection == .udp {
            if let minPort = parsePort(minPortText) {
                input.minPort = minPort
                
            } else if !minPortText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                SystemAlert.error("Invalid min port")
                return nil
            }
            
            if let maxPort = parsePort(maxPortText) {
                input.maxPort = maxPort
                
            } else if !maxPortText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                SystemAlert.error("Invalid max port")
                return nil
            }
            
            let min = input.minPort ?? 1
            let max = input.maxPort ?? 65535
            
            if min > max {
                SystemAlert.error("Min port must be less than or equal to max port")
                return nil
            }
            
            input.minPort = min
            input.maxPort = max
        }
        
        let trimmedNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedNotes.isEmpty {
            input.notes = trimmedNotes
        }
        
        return input
    }
    
    private func parsePort(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let value = Int(trimmed), (1...65535).contains(value) else { return nil }
        
        return value
    }
    
    private func applyDefaultPortsIfNeeded(for proto: VDSProtectionProtocol) {
        guard proto == .tcp || proto == .udp else { return }
        
        if minPortText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            minPortText = "1"
        }
        
        if maxPortText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            maxPortText = "65535"
        }
    }
}

#Preview {
    ProtectionProfileEditor(.create)
        .environment(VDSProtectionVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
