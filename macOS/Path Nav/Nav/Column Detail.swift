import SwiftUI

struct ColumnDetail: View {
    @Environment(NavModel.self) private var nav
    
    private let tab: PanelTab?
    
    init(_ tab: PanelTab? = nil) {
        self.tab = tab
    }
    
    private var activeTab: PanelTab? {
        if let tab {
            tab
        } else {
            nav.selectedTab
        }
    }
    
    var body: some View {
        if let server = nav.selectedServers.first {
            let id = server.id
            
            switch activeTab {
            case .logs:
                LogList(id)
                
            case nil:
                Text("Select a section")
                
            default:
                Text("Oops...")
            }
        }
    }
}

#Preview {
    ColumnDetail()
}
