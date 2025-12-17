import ScrechKit

struct GameServiceInfoSection: View {
    private let service: BillingGameServiceDetails
    
    init(_ service: BillingGameServiceDetails) {
        self.service = service
    }
    
    var body: some View {
        let ram = formatMegaBytes(service.packageInfo.memory)
        let disk = formatMegaBytes(service.packageInfo.disk)
        let diskType = service.packageInfo.diskType ?? ""
        let cpuName = service.packageInfo.cpuName ?? ""
        let cpuCores = service.packageInfo.cpu.clean
        let network = service.packageInfo.network.clean
        let networkType = service.packageInfo.networkType ?? ""
        
        BillingSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Package", value: service.packageInfo.name)
                LabeledContent("CPU", value: "\(cpuCores) vCPU \(cpuName)")
                LabeledContent("RAM", value: ram)
                LabeledContent("Disk", value: "\(disk) \(diskType)")
                LabeledContent("Network", value: "\(network) \(networkType)")
                
                if let expires = service.expiresAt {
                    LabeledContent("Expires", value: expires.formatted(date: .numeric, time: .shortened))
                }
            }
            .footnote()
        }
    }
}
