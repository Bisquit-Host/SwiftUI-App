import SwiftUI
import BisquitoNet

struct ProtectionProfileEditor: View {
    @Environment(VDSProtectionVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let mode: CloudProtectionProfileEditorMode
    
    init(_ mode: CloudProtectionProfileEditorMode) {
        self.mode = mode
    }
    
    @State private var presetId = 0
    @State private var protocolSelection: VDSProtectionProtocol = .tcp
    @State private var notesText = ""
    @State private var singlePort = false
    @State private var minPortText = ""
    @State private var maxPortText = ""
    
    private var selectedProtocolPresets: [VDSProtectionPreset] {
        vm.presets.filter {
            $0.`protocol` == protocolSelection
        }
    }
    
    private var showPortFields: Bool {
        protocolSelection == .tcp || protocolSelection == .udp
    }
    
    var body: some View {
        ScrollView {
            ProtectionProfileEditorPresetSection($presetId, selectedProtocolPresets: selectedProtocolPresets)
            
            ServiceSectionCard("Protocol") {
                Picker("Protocol", selection: $protocolSelection) {
                    ForEach(VDSProtectionProtocol.allCases) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Single port", isOn: $singlePort)
                
                if showPortFields {
                    if singlePort {
                        TextField("Port (1–65535)", text: $minPortText)
                            .keyboardType(.numberPad)
                            .textInputAutocapitalization(.never)
                            .limitInputLength($minPortText, length: 5)
                            .onChange(of: minPortText) { _, newValue in
                                maxPortText = newValue
                            }
                    } else {
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

            selectInitialPreset(from: vm.presets)
        }
        .onChange(of: vm.presets) { _, newPresets in
            if newPresets.contains(where: { $0.id == presetId }) {
                return
            }

            selectInitialPreset(from: newPresets)
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

    private func selectInitialPreset(from presets: [VDSProtectionPreset]) {
        if let tcpPreset = presets.first(where: { $0.`protocol` == .tcp }) {
            presetId = tcpPreset.id
            protocolSelection = .tcp
            applyDefaultPortsIfNeeded(for: .tcp)
            return
        }

        if let first = presets.first {
            presetId = first.id
            protocolSelection = first.`protocol`
            applyDefaultPortsIfNeeded(for: first.`protocol`)
        }
    }
}

#Preview {
    ProtectionProfileEditor(.create)
        .environment(VDSProtectionVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
