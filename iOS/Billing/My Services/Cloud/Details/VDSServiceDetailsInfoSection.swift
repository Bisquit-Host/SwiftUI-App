import SwiftUI

struct VDSServiceDetailsInfoSection: View {
    private let service: CloudServiceDetails
    
    init(_ service: CloudServiceDetails) {
        self.service = service
    }
    
    @State private var sheetReinstall = false
    
    var body: some View {
        VDSSectionCard("Details") {
            let disk = (service.packageInfo.disk / 1024).formatted(.fractionDigits(0))
            let memory = (service.packageInfo.memory / 1024).formatted(.fractionDigits(1))
            let cpu = (service.packageInfo.cpu / 1024).formatted(.fractionDigits(1))
            
            VStack(alignment: .leading, spacing: 10) {
                if let ip = service.ip {
                    LabeledContent("IP", value: ip)
                }
                
                LabeledContent("CPU", value: "\(cpu) vCPU \(service.packageInfo.cpuName ?? "")")
                LabeledContent("RAM", value: "\(memory) GB")
                LabeledContent("Disk", value: "\(disk) GB \(service.packageInfo.diskType ?? "")")
                
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
            VDSReinstallSection(serviceId: service.id)
        }
    }
}

