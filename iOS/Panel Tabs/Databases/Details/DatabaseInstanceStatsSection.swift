import ScrechKit

struct DatabaseInstanceStatsSection: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    var body: some View {
        let resources = vm.resources
        let offline = vm.isOffline
        
        Section("Resources") {
            DatabaseInstanceStatRow(
                "Uptime",
                systemImage: "clock",
                value: offline ? String(localized: "Offline") : Converter.millisecondsToTime(Int(resources?.uptime ?? 0))
            )
            
            DatabaseInstanceStatRow(
                "CPU",
                systemImage: "cpu",
                value: offline ? String(localized: "Offline") : (resources?.cpuAbsolute ?? 0).formatted(.percent.scale(1).precision(.fractionLength(2))),
                limit: DatabaseInstanceLimit.cpu(vm.instance.cpu)
            )
            
            DatabaseInstanceStatRow(
                "Memory",
                systemImage: "memorychip",
                value: offline ? String(localized: "Offline") : formatBytes(resources?.memoryBytes ?? 0, countStyle: .memory),
                limit: DatabaseInstanceLimit.megabytes(vm.instance.memory, countStyle: .memory)
            )
            
            DatabaseInstanceStatRow(
                "Disk",
                systemImage: "internaldrive",
                value: formatBytes(resources?.diskBytes ?? 0),
                limit: DatabaseInstanceLimit.megabytes(vm.instance.disk)
            )
        }
    }
}

#Preview {
    List {
        DatabaseInstanceStatsSection()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
