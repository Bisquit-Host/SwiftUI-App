import SwiftUI
import PteroNet

struct StatRows: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
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
                StatRowSubdomains(server.id)
                
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
