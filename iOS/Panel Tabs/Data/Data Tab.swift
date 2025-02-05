import SwiftUI
import PteroNet

struct DataTab: View {
    @Environment(BackupVM.self) private var backupVM
    @Environment(DatabaseVM.self) private var databaseVM
    @Environment(ScheduleVM.self) private var scheduleVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        List {
            BackupList(server)
#if os(tvOS)
            Divider()
            
            ScheduleList()
                .padding(.vertical)
            
            Divider()
#else
            ScheduleList()
#endif
            DatabaseList(databaseLimit)
        }
        .scrollIndicators(.hidden)
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            fetchData()
        }
    }
    
    private func fetchData() {
        backupVM.fetchBackups()
        databaseVM.fetchDatabases()
        scheduleVM.fetchSchedules()
    }
}

#Preview {
    DataTab(sampleJSON(.serverListAttributes))
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
}

fileprivate extension DataTab {
    var databaseLimit: Int {
        server.featureLimits.databases
    }
}
