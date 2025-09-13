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
            
//            Spacer()
//            
//            Section {
//                Button("Account", systemImage: "person.crop.circle") {
//                    
//                }
//                
//                Button("Settings", systemImage: "gear") {
//                    
//                }
//            }
//            .buttonStyle(.plain)
        }
        .listStyle(.sidebar)
        .frame(minWidth: 400)
    }
}
