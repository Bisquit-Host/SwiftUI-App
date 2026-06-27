import SwiftUI

struct ServerSettingsAutoKillSection: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Section("Forced Auto-Kill") {
            Toggle("Enabled", isOn: $vm.autoKillEnabled)
            
            Stepper(value: $vm.autoKillSeconds, in: 1...3600, step: 30) {
                LabeledContent("Delay") {
                    HStack(spacing: 2) {
                        Text(vm.autoKillSeconds, format: .number)
                        Text("seconds")
                    }
                }
            }
            .disabled(!vm.autoKillEnabled)
            .opacity(vm.autoKillEnabled ? 1 : 0.5)
        }
        .onChange(of: vm.autoKillEnabled) {
            save()
        }
        .onChange(of: vm.autoKillSeconds) {
            save()
        }
    }
    
    private func save() {
        vm.scheduleAutoKillSave()
    }
}

#Preview {
    List {
        ServerSettingsAutoKillSection()
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
