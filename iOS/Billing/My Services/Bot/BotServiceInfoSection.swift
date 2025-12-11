import SwiftUI

struct BotServiceInfoSection: View {
    @Environment(BotServiceDetailsVM.self) private var vm
    
    var body: some View {
        if let service = vm.service {
            BillingSectionCard("Details") {
                VStack(alignment: .leading, spacing: 10) {
                    LabeledContent("Package", value: service.packageInfo.name)
                    LabeledContent("CPU", value: "\(service.packageInfo.cpu.clean) vCPU \(service.packageInfo.cpuName ?? "")")
                    LabeledContent("RAM", value: "\(service.packageInfo.memory.clean) GB")
                    LabeledContent("Disk", value: "\(service.packageInfo.disk.clean) GB \(service.packageInfo.diskType ?? "")")
                    
                    if let expires = service.expiresAt {
                        LabeledContent("Expires", value: expires.formatted(date: .numeric, time: .shortened))
                    }
                }
                .footnote()
            }
        }
    }
}
