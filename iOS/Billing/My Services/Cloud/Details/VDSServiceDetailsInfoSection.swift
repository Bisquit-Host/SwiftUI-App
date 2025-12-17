import ScrechKit

struct VDSServiceDetailsInfoSection: View {
    private let service: CloudServiceDetails
    
    init(_ service: CloudServiceDetails) {
        self.service = service
    }
    
    @State private var sheetReinstall = false
    
    var body: some View {
        let cpu = (service.packageInfo.cpu).formatted(.fractionDigits(1))
        let ram = formatMegaBytes(service.packageInfo.memory)
        let disk = formatMegaBytes(service.packageInfo.disk)
        let cpuName = service.packageInfo.cpuName ?? ""
        let diskType = service.packageInfo.diskType ?? ""
        
        VDSSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                if let ip = service.ip {
                    LabeledContent("IP", value: ip)
                }
                
                LabeledContent("CPU", value: "\(cpu) vCPU \(cpuName)")
                LabeledContent("RAM", value: ram)
                LabeledContent("Disk", value: "\(disk) \(diskType)")
                
                Divider()
                
                if let system = service.system {
                    LabeledContent {
                        VStack(alignment: .trailing) {
                            Text(system)
                            
                            Button("Reinstall") {
                                sheetReinstall = true
                            }
                            .caption2()
                        }
                    } label: {
                        Text("System")
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
            .footnote()
        }
        .sheet($sheetReinstall) {
            NavigationStack {
                VDSReinstallSection(service.id)
            }
        }
    }
}
