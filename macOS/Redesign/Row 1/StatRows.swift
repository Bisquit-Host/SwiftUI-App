import SwiftUI
import Calagopus

struct StatRows: View {
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    static let minHeight = 320.0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatRowBackups(server)
                StatRowUsers(server.id)
                StatRowDatabases(server.id)
//                StatRowSchedules(server.id)
            }
            
            HStack(spacing: 16) {
                StatRowAllocations(server.id)
                
                if server.featureLimits.subdomains ?? 0 > 0 {
                    StatRowSubdomains(server.id)
                }
                
                StatRowSchedules(server.id)
//                StatTile("Modpacks", value: "Browse", icon: "hammer")
//                    .disabled(true)
//                    .opacity(0.5)
//                
//                StatTile("Versions", value: "Browse", icon: "hammer")
//                    .disabled(true)
//                    .opacity(0.5)
            }
        }
        .buttonStyle(.plain)
    }
}
