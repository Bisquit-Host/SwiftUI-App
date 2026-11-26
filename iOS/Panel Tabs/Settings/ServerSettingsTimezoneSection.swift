import ScrechKit

struct ServerSettingsTimezoneSection: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    var body: some View {
        Section("Timezone") {
            NavigationLink {
                ServerSettingsTimezoneList()
                    .environment(vm)
            } label: {
                LabeledContent("Timezone", value: vm.timezone.isEmpty ? "Server default" : vm.timezone)
            }
            
            if vm.hasTimezoneChanges {
                AsyncButton("Save Timezone", systemImage: "checkmark", action: vm.saveTimezone)
                    .disabled(vm.isSavingTimezone)
            }
        }
    }
}

#Preview {
    List {
        ServerSettingsTimezoneSection()
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
