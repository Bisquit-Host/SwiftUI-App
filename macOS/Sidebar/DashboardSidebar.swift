import SwiftUI

struct DashboardSidebar: View {
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection) {
            HStack(spacing: 12) {
                Image(systemName: "cube")
                    .imageScale(.large)
                
                Text("Taskplus")
                    .headline()
            }
            .padding(.vertical, 8)
            
            Section {
                ForEach(SidebarItem.allCases) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }
        }
        .listStyle(.sidebar)
    }
}
