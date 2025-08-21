import SwiftUI

enum OverviewData: String {
    case backups,
         logs,
         users,
         schedules
    //         databases,
}

struct Overview: View {
    @Environment(ServerListVM.self) private var vm
    
    @State private var overviewData: OverviewData?
    
    private let overviewDataTypes: [OverviewData] = [
        .backups,
        .logs,
        .users
    ]
    
    private lazy var allServerIds: [String] = vm.servers.map(\.id)
    
    var body: some View {
        List {
            Picker("Data type", selection: $overviewData) {
                ForEach(overviewDataTypes, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            
            Button("Load data") {
                
            }
            
            Divider()
            
            //            OverviewList()
        }
    }
}

#Preview {
    Overview()
        .environment(ServerListVM())
}
