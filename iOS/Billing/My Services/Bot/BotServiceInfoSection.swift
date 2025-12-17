import ScrechKit

struct BotServiceInfoSection: View {
    private let service: BillingBotServiceDetails
    
    init(_ service: BillingBotServiceDetails) {
        self.service = service
    }
    
    var body: some View {
        BillingSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                let ram = formatMegaBytes(service.packageInfo.memory)
                let disk = formatMegaBytes(service.packageInfo.disk)
                let diskType = service.packageInfo.diskType ?? ""
                let cpuName = service.packageInfo.cpuName ?? ""
                let cpuCores = service.packageInfo.cpu.clean
                
                LabeledContent("Package", value: service.packageInfo.name)
                LabeledContent("CPU", value: "\(cpuCores) vCPU \(cpuName)")
                LabeledContent("RAM", value: ram)
                LabeledContent("Disk", value: "\(disk) \(diskType)")
                
                if let expires = service.expiresAt {
                    LabeledContent("Expires", value: expires.formatted(date: .numeric, time: .shortened))
                }
            }
            .footnote()
        }
    }
}
