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
                .transaction {
                    $0.animation = nil
                }
            }
            
            Button {
                showNewProfileEditor = true
            } label: {
                Label("New Profile", systemImage: "plus")
                    .labelStyle(.iconOnly)
            }
            .tint(.green)
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .disabled(vm.isPerformingAction || vm.isSelectingProfiles)
        }
        .sheet(isPresented: $showNewProfileEditor) {
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
