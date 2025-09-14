import SwiftUI
import PteroNet

struct StatRows: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    //    @State private var sheetBackups = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Button {
//                    sheetBackups = true
                } label: {
                    StatTile("Backups", value: 15, icon: "archivebox")
                }
                
                StatTile("Users", value: 23, icon: "person.2")
                StatTile("Databases", value: 10, icon: "tray")
                StatTile("Shedules", value: 50, icon: "calendar")
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
