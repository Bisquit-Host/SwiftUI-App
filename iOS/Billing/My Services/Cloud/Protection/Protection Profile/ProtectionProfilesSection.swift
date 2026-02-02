import ScrechKit

struct ProtectionProfilesSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
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
    }
}

#Preview {
    ProtectionProfilesSection()
        .environment(VDSProtectionVM())
        .darkSchemePreferred()
}
