import ScrechKit

struct ProtectionProfilesSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @State private var editingProfile: VDSProtectionProfile?
    @State private var deleteCandidate: VDSProtectionProfile?
    
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
                
            }
        } primaryButton: {
            NavigationLink {
                ProtectionProfileEditor(.create)
                    .environment(vm)
            } label: {
                Image(systemName: "plus")
            }
            .tint(.green)
            .buttonStyle(.bordered)
            .disabled(vm.isPerformingAction)
        }
        .navigationDestination(item: $editingProfile) {
            ProtectionProfileEditor(.edit($0))
                .environment(vm)
        }
    }
}

#Preview {
    ProtectionProfilesSection()
        .environment(VDSProtectionVM())
        .darkSchemePreferred()
}
