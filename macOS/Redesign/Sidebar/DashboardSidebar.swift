import SwiftUI

struct DashboardSidebar: View {
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection) {
            Section {
                ServerListGrid([PreviewProp.serverAttributes])
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 400)
    }
}
