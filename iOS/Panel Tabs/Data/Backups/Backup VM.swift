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
    
    func deleteBackups(_ offsets: IndexSet) async {
        for index in offsets {
            let uuid = backups[index].uuid
            await deleteBackup(uuid)
        }
    }
    
    func fetchBackups() async {
        do {
            let backups: BackupListResponse? = try await dataListAPI(
                id,
                endpoint: .backups
            )
            
            if let backups = backups?.data.map(\.attributes) {
                self.backups = backups
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func toggleBackupLock(_ uuid: String) async {
        do {
            let backup = try await backupLockAPI(id, uuid: uuid)
            
            if let index = self.backups.firstIndex(where: {
                $0.uuid == backup.uuid
            }) {
                self.backups[index] = backup
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createBackup() async {
        do {
            let backup = try await backupCreateAPI(id, name: textCreateBackup)
            self.backups.append(backup)
        } catch {
            SystemAlert.error(error)
        }
        
        textCreateBackup = ""
    }
    
    func deleteBackup(_ uuid: String) async {
        do {
            try await dataDeleteAPI(id, itemId: uuid, endpoint: .backups)
        } catch {
            SystemAlert.error(error)
        }
        
        await fetchBackups()
    }
    
    func restoreBackup(_ uuid: String, truncate: Bool) async {
        do {
            try await backupRestoreAPI(id, uuid: uuid, truncate: truncate)
            await SystemAlert.restored()
        } catch {
            SystemAlert.error(error)
        }
    }
}
