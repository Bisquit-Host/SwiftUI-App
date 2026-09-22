import ScrechKit

struct VDSServiceDetailsInfoSection: View {
    private let service: CloudServiceDetails?
    
    init(_ service: CloudServiceDetails?) {
        self.service = service
    }
    
    var body: some View {
        let cpu = service?.packageInfo.cpu.formatted(.fractionDigits(1)) ?? "2.0"
        let ram = service.map { formatMegaBytes($0.packageInfo.memory) } ?? "4 GB"
        let disk = service.map { formatMegaBytes($0.packageInfo.disk) } ?? "40 GB"
        let cpuName = service?.packageInfo.cpuName ?? ""
        let diskType = service?.packageInfo.diskType ?? ""
        
        ServiceSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                if let ip = service == nil ? "192.0.2.1" : service?.ip {
                    LabeledContent("IP") {
                        Text(ip)
                            .redacted(reason: service == nil ? .placeholder : [])
                    }
                }
                
                LabeledContent("CPU") {
                    Text("\(cpu) vCPU \(cpuName)")
                        .redacted(reason: service == nil ? .placeholder : [])
                }
                
                LabeledContent("RAM") {
                    Text(ram)
                        .redacted(reason: service == nil ? .placeholder : [])
                }
                
                LabeledContent("SSD") {
                    Text("\(disk) \(diskType)")
                        .redacted(reason: service == nil ? .placeholder : [])
                }
                
                if let system = service == nil ? "Linux" : service?.system {
                    LabeledContent("System") {
                        Text(system)
                            .redacted(reason: service == nil ? .placeholder : [])
                    }
                }
            }
            .footnote()
        }
    }
}
