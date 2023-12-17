import SwiftUI
import PteroNet

struct DataTab: View {
    @Environment(DataTabVM.self) private var vm
    
    private let id: String
    private let limits: ServerListFeatureLimits
    
    init(_ id: String,
         limits: ServerListFeatureLimits
    ) {
        self.id = id
        self.limits = limits
    }
    
    var body: some View {
        List {
            BackupList(limits.backups)
#if os(tvOS)
            Divider()
            
            ScheduleList()
                .padding(.vertical)
            
            Divider()
#else
            ScheduleList()
#endif
            DatabaseList(limits.databases)
        }
        .scrollIndicators(.hidden)
        .task {
            vm.fetchData()
        }
        .refreshable {
            vm.fetchData()
        }
    }
}

#Preview {
    DataTab("", limits: ServerListFeatureLimits(backups: 5, databases: 5))
        .environment(DataTabVM(""))
}
