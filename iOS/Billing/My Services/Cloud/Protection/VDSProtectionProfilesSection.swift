import ScrechKit

struct VDSProtectionProfilesSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @State private var editingProfile: VDSProtectionProfile?
    @State private var deleteCandidate: VDSProtectionProfile?
    @State private var showDeleteDialog = false
    
    var body: some View {
        VDSSectionCard("Profiles") {
            if vm.isLoading && vm.profiles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
                
            } else if vm.profiles.isEmpty {
                Text("No profiles yet")
                    .footnote()
                    .secondary()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(vm.profiles) { profile in
                        VDSProtectionProfileCard(profile, presetName: presetName(for: profile)) {
                            editingProfile = profile
                        } onDelete: {
                            deleteCandidate = profile
                            showDeleteDialog = true
                        }
                    }
                }
            }
        } primaryButton: {
            NavigationLink {
                VDSProtectionProfileEditorSheet(mode: .create)
                    .environment(vm)
            } label: {
                Image(systemName: "plus")
            }
            .tint(.green)
            .buttonStyle(.bordered)
            .disabled(vm.isPerformingAction)
        }
        .navigationDestination(item: $editingProfile) {
            VDSProtectionProfileEditorSheet(mode: .edit($0))
                .environment(vm)
        }
        .confirmationDialog("Delete profile?", isPresented: $showDeleteDialog, titleVisibility: .visible) {
            if let profile = deleteCandidate {
                Button("Delete", role: .destructive) {
                    Task {
                        await vm.deleteProfile(profile.id)
                        deleteCandidate = nil
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {
                deleteCandidate = nil
            }
        } message: {
            if let profile = deleteCandidate {
                Text(presetName(for: profile))
            }
        }
    }
    
    private func presetName(for profile: VDSProtectionProfile) -> String {
        if let name = profile.presetName, !name.isEmpty {
            return name
        }
        
        if let preset = vm.presets.first(where: { $0.id == profile.presetId }) {
            return preset.name
        }
        
        return "Preset #\(profile.presetId)"
    }
}

#Preview {
    VDSProtectionProfilesSection()
        .environment(VDSProtectionVM())
        .padding()
        .darkSchemePreferred()
}
