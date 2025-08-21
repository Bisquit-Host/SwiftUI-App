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
                .listRowBackground(Color.gray.opacity(0.2))
#if os(tvOS)
            Divider()
            
            ScheduleList()
                .padding(.vertical)
            
            Divider()
#else
            ScheduleList()
                .listRowBackground(Color.gray.opacity(0.2))
#endif
            DatabaseList(databaseLimit)
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollIndicators(.hidden)
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            await fetchData()
        }
        .sheet($scheduleVM.sheetCreate) {
            NewScheduleSheet()
        }
#if !os(tvOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .alert("Create Database", isPresented: $databaseVM.alertCreate) {
            TextField("", text: $databaseVM.newDatabaseName)
                .autocorrectionDisabled()
                .limitInputLength($databaseVM.newDatabaseName, length: 48)
            
            Button("Create") {
                createDatabase()
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
                createBackup()
            }
        }
    }
    
    private func createBackup() {
        Task {
            await backupVM.createBackup()
        }
    }
    
    private func createDatabase() {
        Task {
            await dbVM.createDatabase()
        }
    }
    
    private func fetchData() async {
        await backupVM.fetchBackups()
        await dbVM.fetchDatabases()
        await scheduleVM.fetchSchedules()
    }
}

fileprivate extension DataTab {
    var databaseLimit: Int {
        server.featureLimits.databases
    }
}

#Preview {
    DataTab(sampleJSON(.serverListAttributes))
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
        .darkSchemePreferred()
}
