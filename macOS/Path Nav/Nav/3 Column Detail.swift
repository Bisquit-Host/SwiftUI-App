import SwiftUI

struct ThreeColumnDetail: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        if let server = nav.selectedServers.first {
            let id = server.id
            
            switch nav.selectedTab {
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
    ThreeColumnDetail()
}
