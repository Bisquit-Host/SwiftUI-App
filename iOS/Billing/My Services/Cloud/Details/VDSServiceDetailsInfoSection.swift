import ScrechKit

struct VDSServiceDetailsInfoSection: View {
    private let service: CloudServiceDetails
    
    init(_ service: CloudServiceDetails) {
        self.service = service
    }
    
    var body: some View {
        let cpu = (service.packageInfo.cpu).formatted(.fractionDigits(1))
        let ram = formatMegaBytes(service.packageInfo.memory)
        let disk = formatMegaBytes(service.packageInfo.disk)
        let cpuName = service.packageInfo.cpuName ?? ""
        let diskType = service.packageInfo.diskType ?? ""
        
        ServiceSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                if let ip = service.ip {
                    LabeledContent("IP", value: ip)
                }
                
                LabeledContent("CPU", value: "\(cpu) vCPU \(cpuName)")
                LabeledContent("RAM", value: ram)
                LabeledContent("SSD", value: "\(disk) \(diskType)")
                
                if let system = service.system {
                    LabeledContent("System", value: system)
                }
            }
            .footnote()
        }
    }
}
