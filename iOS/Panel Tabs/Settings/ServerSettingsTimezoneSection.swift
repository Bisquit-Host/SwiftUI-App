import SwiftUI

struct ServerSettingsTimezoneSection: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    private let timezones = TimeZone.knownTimeZoneIdentifiers
    
    var body: some View {
        @Bindable var vm = vm
        
        Section("Timezone") {
            Picker("Timezone", selection: $vm.timezone) {
                Text("Server default").tag("")
                
                ForEach(timezones, id: \.self) {
                    Text($0).tag($0)
                }
            }
            
            if vm.hasTimezoneChanges {
                Button("Save Timezone", systemImage: "checkmark", action: save)
                    .disabled(vm.isSavingTimezone)
            }
        }
    }
    
    private func save() {
        Task {
            await vm.saveTimezone()
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
