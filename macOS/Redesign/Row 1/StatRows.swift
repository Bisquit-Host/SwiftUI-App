import SwiftUI
import PteroNet

struct StatRows: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatRowBackups(server)
                
                StatRowUsers(server.id)
                
                StatRowDatabases(server.id)
                
                StatRowSchedules(server.id)
            }
            
            HStack(spacing: 16) {
                StatRowAllocations(server.id)
                
                StatRowSubdomains(server.id)
                
                StatTile("Modpacks", value: 10, icon: "hammer")
                    .disabled(true)
                    .opacity(0.5)
                
                StatTile("Versions", value: 50, icon: "hammer")
                    .disabled(true)
                    .opacity(0.5)
            }
        }
        .buttonStyle(.plain)
    }
}
