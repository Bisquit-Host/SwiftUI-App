import ScrechKit

struct ServiceInfoSection: View {
    private let service: BillingServiceDetails
    
    init(_ service: BillingServiceDetails) {
        self.service = service
    }
    
    var body: some View {
        let ram = formatMegaBytes(service.packageInfo.memory)
        let disk = formatMegaBytes(service.packageInfo.disk)
        let diskType = service.packageInfo.diskType ?? ""
        let cpuName = service.packageInfo.cpuName ?? ""
        let cpuCores = service.packageInfo.cpu.clean
        let network = service.packageInfo.network?.clean
        let networkType = service.packageInfo.networkType
        
        ServiceSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Package", value: service.packageInfo.name)
                LabeledContent("CPU", value: "\(cpuCores) vCPU \(cpuName)")
                LabeledContent("RAM", value: ram)
                LabeledContent("SSD", value: "\(disk) \(diskType)")
                
                if let network, let networkType {
                    LabeledContent("Network", value: "\(network) \(networkType)")
                }
                
            }
            .footnote()
        }
    }
}
