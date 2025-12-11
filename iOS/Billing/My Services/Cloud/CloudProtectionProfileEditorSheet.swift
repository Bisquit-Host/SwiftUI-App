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
    @State private var listIdText: String
    @State private var notesText: String
    
    init(mode: Mode) {
        self.mode = mode
        
        let existing = mode.existingProfile
        
        _presetId = State(initialValue: existing?.presetId)
        _protocolSelection = State(initialValue: existing?.`protocol` ?? .tcp)
        _minPortText = State(initialValue: existing?.minDstPort.map(String.init) ?? "")
        _maxPortText = State(initialValue: existing?.maxDstPort.map(String.init) ?? "")
        _listIdText = State(initialValue: "")
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
                            Picker("Preset", selection: $presetId) {
                                ForEach(vm.presets) { preset in
                                    Text("\(preset.name) • \(preset.`protocol`.rawValue)")
                                        .tag(Optional(preset.id))
                                }
                            }
                            .pickerStyle(.menu)
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
                            
                            HStack(spacing: 10) {
                                TextField("Min port", text: $minPortText)
                                    .keyboardType(.numberPad)
                                    .textInputAutocapitalization(.never)
                                
                                TextField("Max port", text: $maxPortText)
                                    .keyboardType(.numberPad)
                                    .textInputAutocapitalization(.never)
                            }
                            
                            TextField("List ID (optional)", text: $listIdText)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                            
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
                }
            }
            .onChange(of: presetId) { _, newValue in
                if let id = newValue, let preset = vm.presets.first(where: { $0.id == id }) {
                    protocolSelection = preset.`protocol`
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
            listId: nil,
            notes: nil
        )
        
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
        
        if let min = input.minPort, let max = input.maxPort, min > max {
            SystemAlert.error("Min port must be less than or equal to max port")
            return nil
        }
        
        let trimmedListId = listIdText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedListId.isEmpty {
            guard let listId = Int(trimmedListId), listId > 0 else {
                SystemAlert.error("Invalid list ID")
                return nil
            }
            input.listId = listId
        }
        
        let trimmedNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNotes.isEmpty {
            input.notes = trimmedNotes
        }
        
        return input
    }
    
    private func parsePort(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let value = Int(trimmed), (0...65535).contains(value) else { return nil }
        return value
    }
}

#Preview {
    CloudProtectionProfileEditorSheet(mode: .create)
        .environment(CloudProtectionVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
