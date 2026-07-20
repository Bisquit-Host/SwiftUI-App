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
    
    func deleteBackups(_ offsets: IndexSet) async {
        let backupIDs = offsets.map { backups[$0].uuid }

        for uuid in backupIDs {
            await deleteBackup(uuid)
        }
    }

    func isDeleting(_ backup: CalagopusServerBackup) -> Bool {
        deletingBackupIDs.contains(backup.uuid) || backup.deletionStatus == .deleting
    }
    
    func fetchBackups() async {
        do {
            backups = try await loadBackups()
        } catch {
            SystemAlert.error(error)
        }
    }

    func fetchBackupGroupsIfNeeded() async {
        guard !hasLoadedBackupGroups else {
            return
        }

        do {
            backupGroups = try await CalagopusNet.client().backupGroups(server: id)
            hasLoadedBackupGroups = true
        } catch CalagopusError.httpStatus(let statusCode, _, _) where statusCode == 401 || statusCode == 403 {
            backupGroups = []
            hasLoadedBackupGroups = true
        } catch {
            return
        }
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
        var lastError: Error?

        for _ in 0..<30 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                break
            }

            do {
                backups = try await loadBackups()
                lastError = nil
            } catch {
                lastError = error
                continue
            }

            guard let backup = backups.first(where: { $0.uuid == uuid }) else {
                break
            }

            if backup.deletionStatus == .failed {
                break
            }
        }

        deletingBackupIDs.remove(uuid)

        if let lastError, backups.contains(where: { $0.uuid == uuid }) {
            SystemAlert.error(lastError)
        }
    }

    private func loadBackups() async throws -> [CalagopusServerBackup] {
        try await CalagopusNet.client().backups(server: id).data
    }
}
