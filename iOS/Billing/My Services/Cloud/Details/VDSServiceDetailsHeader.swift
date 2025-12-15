import SwiftUI

struct VDSServiceDetailsHeader: View {
    let service: CloudServiceDetails
    
    @State private var showVNC = false
    
    var body: some View {
        HStack(spacing: 10) {
            Button("Console", systemImage: "display") {
                showVNC = true
            }
            .footnote()
            .foregroundStyle(.blue)
        }
        .safariCover($showVNC, url: "https://test-my.bisquit.host/cloud/\(service.id)?tab=console")
    }
}
