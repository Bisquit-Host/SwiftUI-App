import SwiftUI
import PteroNet

struct DataTab: View {
    @Environment(BackupVM.self) private var backupVM
    @Environment(DatabaseVM.self) private var databaseVM
    @Environment(ScheduleVM.self) private var scheduleVM
    
    private let id: String
    private let limits: ServerFeatureLimits
    
    init(_ id: String,
         limits: ServerFeatureLimits
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
            fetchData()
        }
        .refreshable {
            fetchData()
        }
    }
    
    func fetchData() {
        backupVM.fetchBackups()
        databaseVM.fetchDatabases()
        scheduleVM.fetchSchedules()
    }
}

#Preview {
    DataTab("", limits: ServerFeatureLimits(backups: 5, databases: 5, allocations: 5))
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
}
