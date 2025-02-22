import ScrechKit
import PteroNet

@Observable
final class BackupVM {
    let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var backups: [BackupAttributes] = []
    var textCreateBackup = ""
    var alertCreateBackup = false
    
    var dateAndTime: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    func deleteBackups(_ offsets: IndexSet) {
        for index in offsets {
            let uuid = backups[index].uuid
            
            deleteBackup(uuid)
        }
    }
    
    func fetchBackups() {
        dataListAPI(id, endpoint: .backups) { (result: Result<BackupListResponse?, Error>) in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.backups = model.map(\.attributes)
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func lockBackup(_ uuid: String) {
        backupLockAPI(id, uuid: uuid) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    if let index = self.backups.firstIndex(where: {
                        $0.uuid == model.uuid
                    }) {
                        self.backups[index] = model
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func createBackup() {
        backupCreateAPI(id, name: textCreateBackup) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    withAnimation {
                        self.backups.append(model)
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
        
        textCreateBackup = ""
    }
    
    func deleteBackup(_ uuid: String) {
        dataDeleteAPI(id, itemId: uuid, endpoint: .backups) { result in
            switch result {
            case .success:
                self.fetchBackups()
                
            case .failure(let error):
                SystemAlert.error(error)
                
                self.fetchBackups()
            }
        }
    }
    
    func restoreBackup(_ uuid: String, truncate: Bool) {
        backupRestoreAPI(id, uuid: uuid, truncate: truncate) { result in
            switch result {
            case .success:
                SystemAlert.restored()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
