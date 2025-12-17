import ScrechKit

struct GameServiceInfoSection: View {
    @Environment(GameServiceDetailsVM.self) private var vm
    
    var body: some View {
        if let service = vm.service {
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
}
