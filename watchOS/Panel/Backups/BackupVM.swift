import SwiftUI
import Calagopus

@Observable
final class BackupVM {
    let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var backups: [CalagopusServerBackup] = []
    private(set) var backupGroups: [CalagopusServerBackupGroup] = []
    private(set) var deletingBackupIDs: Set<String> = []
    var textCreateBackup = ""
    var selectedBackupGroupID: String?
    var alertCreateBackup = false
    private var hasLoadedBackupGroups = false
    
    var dateAndTime: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    func fetchBackups() async {
        do {
            backups = try await CalagopusNet.client().backups(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }

    func fetchBackupGroupsIfNeeded() async {
        guard !hasLoadedBackupGroups else {
            return
        }

        hasLoadedBackupGroups = true
        backupGroups = (try? await CalagopusNet.client().backupGroups(server: id)) ?? []
    }
    
    func toggleBackupLock(_ uuid: String) async {
        do {
            let locked = !(backups.first(where: { $0.uuid == uuid })?.isLocked ?? false)
            try await CalagopusNet.client().lockBackup(server: id, backup: uuid, locked: locked)
            await fetchBackups()
        } catch {
            SystemAlert.error(error)
        }
    }

    func isDeleting(_ backup: CalagopusServerBackup) -> Bool {
        deletingBackupIDs.contains(backup.uuid) || backup.deletionStatus == .deleting
    }
    
    func createBackup() async {
        do {
            let backupName = textCreateBackup.isEmpty ? "Backup at \(dateAndTime)" : textCreateBackup
            let backup = try await CalagopusNet.client().createBackup(
                server: id,
                name: backupName,
                backupGroupID: selectedBackupGroupID
            )
            self.backups.append(backup)
        } catch {
            SystemAlert.error(error)
        }
        
        textCreateBackup = ""
    }
    
    func deleteBackup(_ uuid: String) async {
        guard let backup = backups.first(where: { $0.uuid == uuid }),
              !backup.isLocked,
              !isDeleting(backup) else {
            return
        }

        deletingBackupIDs.insert(uuid)

        do {
            try await CalagopusNet.client().deleteBackup(server: id, backup: uuid)
        } catch {
            deletingBackupIDs.remove(uuid)
            SystemAlert.error(error)
            return
        }

        await waitForBackupDeletion(uuid)
    }
    
    func restoreBackup(_ uuid: String, truncate: Bool) async {
        do {
            try await CalagopusNet.client().restoreBackup(server: id, backup: uuid, truncate: truncate)
            SystemAlert.restored()
        } catch {
            SystemAlert.error(error)
        }
    }

    private func waitForBackupDeletion(_ uuid: String) async {
        for _ in 0..<30 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                break
            }

            await fetchBackups()

            guard let backup = backups.first(where: { $0.uuid == uuid }) else {
                break
            }

            if backup.deletionStatus == .failed {
                break
            }
        }

        deletingBackupIDs.remove(uuid)
    }
}
