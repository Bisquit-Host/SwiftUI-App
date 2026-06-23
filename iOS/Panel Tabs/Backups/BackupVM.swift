import SwiftUI
import Calagopus

@Observable
final class BackupVM {
    let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var backups: [CalagopusServerBackup] = []
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
            backups = try await CalagopusNet.client().backups(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func toggleBackupLock(_ uuid: String) async {
        do {
            try await CalagopusNet.client().lockBackup(server: id, backup: uuid, locked: true)
            if let index = backups.firstIndex(where: { $0.uuid == uuid }) {
                backups[index] = try await CalagopusNet.client().backups(server: id).data[index]
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createBackup() async {
        do {
            let backupName = textCreateBackup.isEmpty ? "Backup at \(dateAndTime)" : textCreateBackup
            let backup = try await CalagopusNet.client().createBackup(server: id, name: backupName)
            self.backups.append(backup)
        } catch {
            SystemAlert.error(error)
        }
        
        textCreateBackup = ""
    }
    
    func deleteBackup(_ uuid: String) async {
        do {
            try await CalagopusNet.client().deleteBackup(server: id, backup: uuid)
        } catch {
            SystemAlert.error(error)
        }
        
        await fetchBackups()
    }
    
    func restoreBackup(_ uuid: String, truncate: Bool) async {
        do {
            try await CalagopusNet.client().restoreBackup(server: id, backup: uuid, truncate: truncate)
            SystemAlert.restored()
        } catch {
            SystemAlert.error(error)
        }
    }
}
