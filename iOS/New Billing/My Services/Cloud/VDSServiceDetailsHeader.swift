import SwiftUI

struct VDSServiceDetailsHeader: View {
    private let service: BillingCloudServiceDetails
    
    init(_ service: BillingCloudServiceDetails) {
        self.service = service
    }
    
    @State private var showVNC = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(service.name)
                    .title3(.bold)
                
                Spacer()
                
                Capsule()
                    .fill(service.state.color.opacity(0.15))
                    .overlay {
                        Text(service.state.title)
                            .footnote(.semibold)
                            .foregroundStyle(service.state.color)
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 30)
            }
            
            HStack(spacing: 10) {
                Text("IP: \(service.ip ?? "n/a")")
                    .footnote()
                    .secondary()
                
                if let system = service.system {
                    Text("• \(system)")
                        .footnote()
                        .secondary()
                }
                
                Button("Console", systemImage: "display") {
                    showVNC = true
                }
                .footnote()
                .foregroundStyle(.blue)
            }
        }
        .safariCover($showVNC, url: "https://test-my.bisquit.host/cloud/\(service.id)?tab=console")
    }
}
