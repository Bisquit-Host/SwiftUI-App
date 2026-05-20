import ScrechKit

struct ProtectionProfilesSection: View {
    @Environment(VDSProtectionVM.self) private var vm
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
                selectionHeader
                ProtectionProfileList()
            }
        } primaryButton: {
            if !vm.profiles.isEmpty {
                Button(vm.isSelectingProfiles ? "Cancel" : "Select") {
                    vm.setProfileSelectionEnabled(!vm.isSelectingProfiles)
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.foreground)
                .disabled(vm.isPerformingAction)
                .transaction { $0.animation = nil }
            }
            
            NavigationLink {
                ProtectionProfileEditor(.create)
                    .environment(vm)
            } label: {
                Image(systemName: "plus")
            }
            .tint(.green)
            .buttonStyle(.bordered)
            .disabled(vm.isPerformingAction || vm.isSelectingProfiles)
        }
        .alert("Delete selected profiles?", isPresented: $showBulkDeleteDialog) {
            Button("Delete", role: .destructive, action: deleteSelectedProfiles)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone")
        }
    }
    
    private var selectionHeader: some View {
        HStack(spacing: 10) {
            if vm.isSelectingProfiles {
                Spacer()
                
                Button("Delete", role: .destructive) {
                    showBulkDeleteDialog = true
                }
                .buttonStyle(.bordered)
                .disabled(vm.selectedProfileIds.isEmpty || vm.isPerformingAction)
            } else {
                Spacer()
            }
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
