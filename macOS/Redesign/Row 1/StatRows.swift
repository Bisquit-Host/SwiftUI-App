import SwiftUI

struct StatRows: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatTile(title: "Backups", value: 15, icon: "archivebox")
                StatTile(title: "Users", value: 23, icon: "person.2")
                StatTile(title: "Databases", value: 10, icon: "tray")
                StatTile(title: "Shedules", value: 50, icon: "calendar")
            }
            
            HStack(spacing: 16) {
                StatTile(title: "Allocations", value: 23, icon: "text.magnifyingglass")
                StatTile(title: "Sudomains", value: 23, icon: "globe")
                
                StatTile(title: "Modpacks", value: 10, icon: "hammer")
                    .disabled(true)
                
                StatTile(title: "Versions", value: 50, icon: "hammer")
                    .disabled(true)
            }
        }
    }
}
