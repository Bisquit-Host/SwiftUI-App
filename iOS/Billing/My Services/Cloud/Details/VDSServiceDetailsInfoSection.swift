import SwiftUI

struct VDSServiceDetailsInfoSection: View {
    private let service: CloudServiceDetails
    
    init(_ service: CloudServiceDetails) {
        self.service = service
    }
    
    var body: some View {
        BillingSectionCard("Details") {
            let disk = (service.packageInfo.disk / 1024).formatted(.fractionDigits(0))
            let memory = (service.packageInfo.memory / 1024).formatted(.fractionDigits(1))
            let cpu = (service.packageInfo.cpu / 1024).formatted(.fractionDigits(1))
            
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Package", value: service.packageInfo.name)
                LabeledContent("CPU", value: "\(cpu) vCPU \(service.packageInfo.cpuName ?? "")")
                LabeledContent("RAM", value: "\(memory) GB")
                LabeledContent("Disk", value: "\(disk) GB \(service.packageInfo.diskType ?? "")")
                LabeledContent("Location", value: service.location.name)
                
                if let expires = service.expiresAt {
                    LabeledContent("Expires", value: expires.formatted(date: .numeric, time: .shortened))
                }
            }
        }
    }
}

