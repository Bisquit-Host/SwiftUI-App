import ScrechKit

struct ServerSettingsAutoStartSection: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Section("Auto-Start") {
            Picker("Behavior", selection: $vm.autoStartBehavior) {
                ForEach(ServerSettingsAutoStartBehavior.allCases) {
                    Text($0.title)
                        .tag($0)
                }
            }
            
            Text(vm.autoStartBehavior.subtitle)
                .secondary()
            
            if vm.hasAutoStartChanges {
                AsyncButton("Save Auto-Start", systemImage: "checkmark", action: vm.saveAutoStart)
                    .disabled(vm.isSavingAutoStart)
            }
        }
    }
}

#Preview {
    List {
        ServerSettingsAutoStartSection()
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
