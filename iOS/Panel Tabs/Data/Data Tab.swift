import SwiftUI
import PteroNet

struct DataTab: View {
    @Environment(BackupVM.self) private var backupVM
    @Environment(DatabaseVM.self) private var dbVM
    @Environment(ScheduleVM.self) private var scheduleVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var backupVM = backupVM
        @Bindable var databaseVM = dbVM
        @Bindable var scheduleVM = scheduleVM
        
        List {
            BackupList(server)
            //                .transparentSection()
                .listRowBackground(Color.gray.opacity(0.2))
#if os(tvOS)
            Divider()
            
            ScheduleList()
                .padding(.vertical)
            
            Divider()
#else
            ScheduleList()
            //                .transparentSection()
                .listRowBackground(Color.gray.opacity(0.2))
#endif
            DatabaseList(databaseLimit)
            //                .transparentSection()
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollIndicators(.hidden)
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            fetchData()
        }
        .sheet($scheduleVM.sheetCreate) {
            NewScheduleSheet()
        }
        .background(BackgroundImage())
#if !os(tvOS)
        .scrollContentBackground(.hidden)
#endif
        .toolbarBackground(.visible, for: .tabBar)
        .alert("Create Database", isPresented: $databaseVM.alertCreate) {
            TextField("", text: $databaseVM.newDatabaseName)
                .autocorrectionDisabled()
                .limitInputLength($databaseVM.newDatabaseName, length: 48)
            
            Button("Create") {
                databaseVM.createDatabase()
            }
            
            Button("Cancel", role: .cancel) {
                databaseVM.newDatabaseName = ""
            }
        }
        .alert("Name Backup", isPresented: $backupVM.alertCreateBackup) {
            TextField("Backup at \(backupVM.dateAndTime)", text: $backupVM.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($backupVM.textCreateBackup, length: 191)
            
            Button("Cancel", role: .cancel) {}
            
            Button("Create") {
                backupVM.createBackup()
            }
        }
    }
    
    private func fetchData() {
        backupVM.fetchBackups()
        dbVM.fetchDatabases()
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
