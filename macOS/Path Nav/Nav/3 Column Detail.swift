import SwiftUI

struct ThreeColumnDetail: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        switch nav.selectedTab {
//        case .logs:
//            Text("Logs")
            
        case nil:
            Text("Select a section")
            
        default:
            Text("Oops...")
        }
    }
}

#Preview {
    ThreeColumnDetail()
}
