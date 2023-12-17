import ScrechKit
import PteroNet

@Observable
final class DataTabVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var backups: [BackupListData] = []
    var databases: [DatabaseData] = []
    var schedules: [ScheduleListData] = []
    var downloadUrl = ""
    var textCreateBackup = ""
    var newDatabaseName = ""
    var alertCreateBackup = false
    var showSafari = false
    var sheetCreateTask = false
    
    func fetchData() {
        fetchBackups()
        fetchDatabases()
        fetchSchedules()
    }
    
    func fetchBackups() {
        getDataListAPI(id, endpoint: .backups) { (result: Result<BackupListResponse?, Error>) in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.backups = model.data
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func downloadBackup(_ uuid: String) {
        downloadBackupAPI(id, uuid: uuid) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    self.downloadUrl = model.url
                    
                    self.showSafari = true
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createSchedule(_ newSchedule: NewSchedule) {
        createScheduleAPI(id, newSchedule: newSchedule) { result in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.schedules.append(model)
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createScheduleTask(_ scheduleId: Int, newTask: NewScheduleTask) {
        createScheduleTaskAPI(id, scheduleId: scheduleId, newTask: newTask) { result in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        if let index = self.schedules.firstIndex(where: { $0.attributes.id == scheduleId }) {
                            self.schedules[index].attributes.relationships.tasks.data.append(model)
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteScheduleTask(_ scheduleId: Int, taskId: Int) {
        deleteScheduleTaskAPI(id, scheduleId: scheduleId, taskId: taskId) { result in
            switch result {
            case .success:
                //                if let index = self.scheduleTasks.firstIndex(where: { $0.attributes.id == taskId }) {
                //                    self.scheduleTasks.remove(at: index)
                //                }
                
                if let scheduleIndex = self.schedules.firstIndex(where: { $0.attributes.id == scheduleId }) {
                    if let taskIndex = self.schedules[scheduleIndex].attributes.relationships.tasks.data.firstIndex(where: { $0.attributes.id == taskId }) {
                        self.schedules[scheduleIndex].attributes.relationships.tasks.data.remove(at: taskIndex)
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func lockBackup(_ uuid: String) {
        lockBackupAPI(id, uuid: uuid) { result in
            switch result {
            case .success(let model):
                if let model {
                    if let index = self.backups.firstIndex(where: { $0.attributes.uuid == model.attributes.uuid }) {
                        self.backups[index] = model
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fetchDatabases() {
        getDataListAPI(id, endpoint: .databases) { (result: Result<DatabaseListResponse?, Error>) in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.databases = model.data
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fetchSchedules() {
        getDataListAPI(id, endpoint: .schedules) { (result: Result<ScheduleListResponse?, Error>) in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.schedules = model.data
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteItems(_ endpoint: DatalistEndpoint, offsets: IndexSet) {
        for index in offsets {
            switch endpoint {
            case .backups:
                let uuid = backups[index].attributes.uuid
                deleteData(uuid, endpoint: .backups)
                
            case .schedules:
                //let uuid = schedules[index].attributes.uuid
                //deleteData(uuid, from: .schedules)
                print("Soon")
                
            case .databases:
                let id = databases[index].attributes.id
                deleteData(id, endpoint: .databases)
            }
        }
    }
    
    func deleteSchedule(_ scheduleId: Int) {
        deleteScheduleAPI(id, scheduleId: scheduleId) { result in
            switch result {
            case .success:
                if let index = self.schedules.firstIndex(where: { $0.attributes.id == scheduleId }) {
                    self.schedules.remove(at: index)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteData(_ uuid: String, endpoint: DatalistEndpoint) {
        deleteDataAPI(id, uuid: uuid, endpoint: endpoint) { result in
            switch result {
            case .success(let model):
                print(model)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
        
        delay {
            switch endpoint {
            case .backups:
                self.fetchBackups()
                
            case .schedules:
                self.fetchSchedules()
                
            case .databases:
                self.fetchDatabases()
            }
        }
    }
    
    func restoreBackup(_ uuid: String, truncate: Bool) {
        restoreBackupAPI(id, uuid: uuid, truncate: truncate) { result in
            switch result {
            case .success:
                print("Restored")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createBackup() {
        createBackupAPI(id, name: textCreateBackup) { result in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.backups.append(model)
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
        
        textCreateBackup = ""
    }
    
    func executeSchedule(_ scheduleId: Int) {
        executeScheduleAPI(id, scheduleId: scheduleId) { result in
            switch result {
            case .success:
                print("Executed")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func rotateDatabasePassword(_ dbId: String) {
        rotateDatabasePasswordAPI(id, dbId: dbId) { result in
            switch result {
            case .success(let model):
                if let model {
                    if let index = self.databases.firstIndex(where: { $0.attributes.id == model.attributes.id }) {
                        self.databases[index] = model
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createDatabase() {
        createDatabaseAPI(id, name: newDatabaseName) { result in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.databases.append(model)
                        self.newDatabaseName = ""
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
