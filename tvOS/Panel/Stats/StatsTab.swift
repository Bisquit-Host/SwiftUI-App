import SwiftUI
import Calagopus

struct StatsTab: View {
    @Environment(PanelVM.self) private var vm
    @Environment(BackupVM.self) private var backupVM
    @Environment(DatabaseVM.self) private var databaseVM
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        let limits = server.limits
        let featureLimits = server.featureLimits
        
        VStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 20) {
                        Text(server.name)
                            .title()
                            .minimumScaleFactor(0.5)
                            .scaledToFit()
                        
                        Circle()
                            .frame(width: 40)
                            .foregroundStyle(vm.stateColor)
                    }
                    
                    Text(server.description ?? "")
                        .callout()
                        .minimumScaleFactor(0.1)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .frame(width: 5, height: 280)
                
                HStack(spacing: 40) {
                    ProgressBar("cpu", progress: vm.cpuUsage / Double(limits.cpu))
                    
                    let ramUsage = vm.ramUsage / pow(1024, 2) / Double(limits.memory)
                    ProgressBar("ram", progress: ramUsage)
                    
                    let ssdUsage = vm.diskUsage / pow(1024, 2) / Double(limits.disk)
                    ProgressBar("ssd", progress: ssdUsage)
                }
                .frame(maxWidth: .infinity)
                .onDisappear {
                    vm.cpuUsage = 0
                    vm.ramUsage = 0
                    vm.diskUsage = 0
                }
                
                Rectangle()
                    .frame(width: 5, height: 280)
                
                VStack(alignment: .leading) {
                    GaugeTV("uptime", param: Converter.millisecondsToTime(vm.uptime))
                    
                    GaugeTV("backups", param: "\(backupVM.backups.count)/\(featureLimits.backups)")
                    
                    GaugeTV("databases", param: "\(databaseVM.databases.count)/\(featureLimits.databases)")
                    
                    GaugeTV("identifier", param: server.id)
                    
                    GaugeTV("node", param: server.nodeName.capitalized)
                }
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            }
            
            Rectangle()
                .frame(height: 5)
            
            HStack(spacing: 0) {
                ChartView(caption: "CPU", unit: "absolute", max: Double(limits.cpu), values: vm.cpuValues)
                    .frame(maxWidth: .infinity)
                
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.gray)
                
                ChartView(caption: "RAM", unit: "GB", max: Double(limits.memory), values: vm.ramValues)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    StatsTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
}
