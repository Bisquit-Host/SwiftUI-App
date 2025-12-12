import SwiftUI

struct VDSServiceDetailsTabView: View {
    let serviceId: Int
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                VDSServiceDetails(serviceId: serviceId)
            }
            
            Tab("Protection", systemImage: "shield.pattern.checkered") {
                CloudProtection(serviceId: serviceId)
            }
        }
    }
}

#Preview {
    VDSServiceDetailsTabView(serviceId: 1)
}
