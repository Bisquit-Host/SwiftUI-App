import SwiftUI

struct CloudProtectionProfileEditorSheet: View {
    enum Mode {
        case create
        case edit(CloudProtectionProfile)
        
        var title: String {
            switch self {
            case .create: "New Profile"
            case .edit: "Edit Profile"
            }
        }
        
        var actionTitle: String {
            switch self {
            case .create: "Create profile"
            case .edit: "Save changes"
            }
        }
        
        var existingProfile: CloudProtectionProfile? {
            if case .edit(let profile) = self { return profile }
            return nil
        }
    }
    
    @Environment(CloudProtectionVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    
    @State private var presetId: Int?
    @State private var protocolSelection: CloudProtectionProtocol
    @State private var minPortText: String
    @State private var maxPortText: String
    @State private var notesText: String
    
    init(mode: Mode) {
        self.mode = mode
        
        let existing = mode.existingProfile
        
        _presetId = State(initialValue: existing?.presetId)
        _protocolSelection = State(initialValue: existing?.`protocol` ?? .tcp)
        _minPortText = State(initialValue: existing?.minDstPort.map(String.init) ?? "")
        _maxPortText = State(initialValue: existing?.maxDstPort.map(String.init) ?? "")
        _notesText = State(initialValue: existing?.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BillingSectionCard("Preset") {
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
                            Menu {
                                ForEach(vm.presets) { preset in
                                    Button {
                                        presetId = preset.id
                                        protocolSelection = preset.`protocol`
                                        applyDefaultPortsIfNeeded(for: preset.`protocol`)
                                    } label: {
                                        Text("\(preset.name) • \(preset.`protocol`.rawValue)")
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedPresetTitle)
                                        .subheadline(.semibold)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .secondary()
                                }
                                .contentShape(.rect)
                            }
                        }
                    }
                    
                    BillingSectionCard("Settings") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Protocol")
                                .subheadline(.semibold)
                            
                            Picker("Protocol", selection: $protocolSelection) {
                                ForEach(CloudProtectionProtocol.allCases) { proto in
                                    Text(proto.rawValue).tag(proto)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            if protocolSelection == .tcp || protocolSelection == .udp {
                                HStack(spacing: 10) {
                                    TextField("Min port (1–65535)", text: $minPortText)
                                        .keyboardType(.numberPad)
                                        .textInputAutocapitalization(.never)
                                    
                                    TextField("Max port (1–65535)", text: $maxPortText)
                                        .keyboardType(.numberPad)
                                        .textInputAutocapitalization(.never)
                                }
                            } else {
                                Text("Ports not applicable for \(protocolSelection.rawValue)")
                                    .footnote()
                                    .secondary()
                            }
                            
                            TextField("Notes (optional)", text: $notesText, axis: .vertical)
                                .textInputAutocapitalization(.sentences)
                        }
                    }
                    
                    Button(mode.actionTitle) {
                        Task { await save() }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isPerformingAction || presetId == nil)
                }
                .scenePadding()
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
            .onAppear {
                if presetId == nil, let first = vm.presets.first {
                    presetId = first.id
                    protocolSelection = first.`protocol`
                    applyDefaultPortsIfNeeded(for: first.`protocol`)
                }
            }
            .onChange(of: presetId) { _, newValue in
                if let id = newValue, let preset = vm.presets.first(where: { $0.id == id }) {
                    protocolSelection = preset.`protocol`
                    applyDefaultPortsIfNeeded(for: preset.`protocol`)
                }
            }
            .onChange(of: protocolSelection) { _, newProto in
                if newProto == .tcp || newProto == .udp {
                    applyDefaultPortsIfNeeded(for: newProto)
                } else {
                    minPortText = ""
                    maxPortText = ""
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
                
                ToolbarSpacer(.flexible, placement: .bottomBar)
            }
        }
    }
    
    private func save() async {
        guard let input = makeInput() else { return }
        
        switch mode {
        case .create:
            await vm.createProfile(input)
        case .edit(let profile):
            await vm.updateProfile(profile.id, input: input)
        }
        
        dismiss()
    }
    
    private func makeInput() -> CloudProtectionProfileInput? {
        guard let presetId else {
            SystemAlert.error("Select a preset")
            return nil
        }
        
        var input = CloudProtectionProfileInput(
            presetId: presetId,
            protocol: protocolSelection,
            minPort: nil,
            maxPort: nil,
            notes: nil
        )
        
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
    
    private var selectedPresetTitle: String {
        if let id = presetId, let preset = vm.presets.first(where: { $0.id == id }) {
            return "\(preset.name) • \(preset.`protocol`.rawValue)"
        }
        return "Select preset"
    }
    
    private func applyDefaultPortsIfNeeded(for proto: CloudProtectionProtocol) {
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
    CloudProtectionProfileEditorSheet(mode: .create)
        .environment(CloudProtectionVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
