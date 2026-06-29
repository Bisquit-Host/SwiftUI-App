import ScrechKit

struct ProtectionProfilesSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @State private var showNewProfileEditor = false
    @State private var showBulkDeleteDialog = false
    
    var body: some View {
        ServiceSectionCard("Profiles") {
            if vm.isLoading && vm.profiles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
                
            } else if vm.profiles.isEmpty {
                Text("No profiles yet")
                    .footnote()
                    .secondary()
            } else {
                ProtectionProfileList()
            }
        } primaryButton: {
            if !vm.profiles.isEmpty && vm.isSelectingProfiles {
                Button("Cancel") {
                    vm.setProfileSelectionEnabled(!vm.isSelectingProfiles)
                }
                .footnote()
                .buttonStyle(.bordered)
                .foregroundStyle(.foreground)
                .disabled(vm.isPerformingAction)
                .transaction {
                    $0.animation = nil
                }
            }
            
            if vm.isSelectingProfiles {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    showBulkDeleteDialog = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .disabled(vm.selectedProfileIds.isEmpty || vm.isPerformingAction)
            }
            
            if !vm.isSelectingProfiles {
                Button("New Profile", systemImage: "plus") {
                    showNewProfileEditor = true
                }
                .labelStyle(.iconOnly)
                .tint(.green)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .disabled(vm.isPerformingAction || vm.isSelectingProfiles)
            }
        }
        .sheet($showNewProfileEditor) {
            NavigationStack {
                ProtectionProfileEditor()
                    .environment(vm)
            }
        }
        .alert("Delete selected profiles?", isPresented: $showBulkDeleteDialog) {
            Button("Delete", role: .destructive, action: deleteSelectedProfiles)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone")
        }
    }
    
    private func deleteSelectedProfiles() {
        Task {
            await vm.deleteSelectedProfiles()
        }
    }
}

#Preview {
    ProtectionProfilesSection()
        .environment(VDSProtectionVM())
        .darkSchemePreferred()
}
