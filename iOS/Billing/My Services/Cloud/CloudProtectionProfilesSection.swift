import SwiftUI

struct CloudProtectionProfilesSection: View {
    @Environment(CloudProtectionVM.self) private var vm
    
    @State private var editingProfile: CloudProtectionProfile?
    @State private var deleteCandidate: CloudProtectionProfile?
    @State private var showDeleteDialog = false
    
    var body: some View {
        BillingSectionCard("Profiles") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    NavigationLink {
                        CloudProtectionProfileEditorSheet(mode: .create)
                            .environment(vm)
                    } label: {
                        Label("Add profile", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .disabled(vm.isPerformingAction)
                    
                    Spacer()
                }
                
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
                            CloudProtectionProfileRow(
                                profile: profile,
                                presetName: presetName(for: profile),
                                onEdit: {
                                    editingProfile = profile
                                },
                                onDelete: {
                                    deleteCandidate = profile
                                    showDeleteDialog = true
                                }
                            )
                        }
                    }
                }
            }
        }
        .sheet(item: $editingProfile) { profile in
            CloudProtectionProfileEditorSheet(mode: .edit(profile))
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
    
    private func presetName(for profile: CloudProtectionProfile) -> String {
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
    CloudProtectionProfilesSection()
        .environment(CloudProtectionVM())
        .padding()
        .darkSchemePreferred()
}
