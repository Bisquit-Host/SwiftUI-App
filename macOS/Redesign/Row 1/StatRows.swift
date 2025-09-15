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
                
                StatTile("Schedules", value: 50, icon: "calendar")
            }
            
            HStack(spacing: 16) {
                StatTile("Allocations", value: 23, icon: "text.magnifyingglass")
                StatTile("Sudomains", value: 23, icon: "globe")
                
                StatTile("Modpacks", value: 10, icon: "hammer")
                    .disabled(true)
                
                StatTile("Versions", value: 50, icon: "hammer")
                    .disabled(true)
            }
        }
        .buttonStyle(.plain)
    }
}
