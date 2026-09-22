import ScrechKit

struct ServiceInfoSection: View {
    private let service: BillingServiceDetails?
    
    init(_ service: BillingServiceDetails?) {
        self.service = service
    }
    
    var body: some View {
        let ram = service.map { formatMegaBytes($0.packageInfo.memory) } ?? "4 GB"
        let disk = service.map { formatMegaBytes($0.packageInfo.disk) } ?? "40 GB"
        let diskType = service?.packageInfo.diskType ?? ""
        let cpuName = service?.packageInfo.cpuName ?? ""
        let cpuCores = service?.packageInfo.cpu.clean ?? "2"
        let network = service == nil ? "1000" : service?.packageInfo.network?.clean
        let networkType = service == nil ? "Mbps" : service?.packageInfo.networkType
        
        ServiceSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Status") {
                    Text(service?.state.title ?? "Active")
                        .foregroundStyle(service?.state.color ?? .secondary)
                        .redacted(reason: service == nil ? .placeholder : [])
                }
                
                LabeledContent("Location") {
                    HStack {
                        FlagIcon(service?.location.flagUrl)

                        Text(service?.location.name ?? "Location name")
                            .redacted(reason: service == nil ? .placeholder : [])
                    }
                }

                LabeledContent("Package") {
                    Text(service?.packageInfo.name ?? "Service package")
                        .redacted(reason: service == nil ? .placeholder : [])
                }
                
                LabeledContent("CPU") {
                    Text("\(cpuCores) vCPU \(cpuName)")
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
                
                if let network, let networkType {
                    LabeledContent("Network") {
                        Text("\(network) \(networkType)")
                            .redacted(reason: service == nil ? .placeholder : [])
                    }
                }
            }
            .footnote()
        }
    }
}
