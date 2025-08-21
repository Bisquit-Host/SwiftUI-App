import SwiftUI
import PteroNet

struct StatsTab: View {
    @Environment(PanelVM.self) private var vm
    @Environment(BackupVM.self) private var backupVM
    @Environment(DatabaseVM.self) private var databaseVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    private var limits: ServerLimits {
        server.limits
    }
    
    private var featureLimits: ServerFeatureLimits {
        server.featureLimits
    }
    
    private let bounds = UIScreen.main.bounds
    
    var body: some View {
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
                    
                    Text(server.description)
                        .callout()
                        .minimumScaleFactor(0.1)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(width: bounds.width * 0.33)
                
                Rectangle()
                    .frame(width: 5, height: 280)
                
                HStack(spacing: 40) {
                    ProgressBar("cpu", progress: vm.cpuUsage / limits.cpu)
                    
                    let ramUsage = vm.ramUsage / pow(1024, 2) / limits.memory
                    ProgressBar("ram", progress: ramUsage)
                    
                    let ssdUsage = vm.diskUsage / pow(1024, 2) / limits.disk
                    ProgressBar("ssd", progress: ssdUsage)
                }
                .frame(width: bounds.width * 0.33)
                .onDisappear {
                    vm.cpuUsage = 0
                    vm.ramUsage = 0
                    vm.diskUsage = 0
                }
                
                Rectangle()
                    .frame(width: 5, height: 280)
                
                VStack(alignment: .leading) {
                    GaugeTV("uptime", param: millisecondsToTime(vm.uptime))
                    
                    GaugeTV("backups", param: "\(backupVM.backups.count)/\(featureLimits.backups)")
                    
                    GaugeTV("databases", param: "\(databaseVM.databases.count)/\(featureLimits.databases)")
                    
                    GaugeTV("identifier", param: server.id)
                    
                    GaugeTV("node", param: server.node.capitalized)
                }
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(minWidth: bounds.width * 0.33, alignment: .leading)
            }
            
            Rectangle()
                .frame(width: bounds.width * 0.9, height: 5)
            
            HStack(spacing: 0) {
                ChartView(
                    "CPU",
                    unit: "absolute",
                    max: limits.cpu,
                    values: vm.cpuValues
                )
                .frame(width: bounds.width * 0.33)
                
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.gray)
                
                ChartView(
                    "RAM",
                    unit: "GB",
                    max: limits.memory,
                    values: vm.ramValues
                )
                .frame(width: bounds.width * 0.33)
            }
        }
    }
}

#Preview {
    StatsTab(sampleJSON(.serverListAttributes))
        .environment(PanelVM(""))
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
}
