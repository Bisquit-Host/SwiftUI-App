import SwiftUI
import OSLog
import Calagopus

@Observable
final class BackupVM {
    let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var backups: [CalagopusServerBackup] = []
    private(set) var systemBackups: [CalagopusServerBackup] = []
    private(set) var backupGroups: [CalagopusServerBackupGroup] = []
    private(set) var deletingBackupIDs: Set<String> = []
    private(set) var isLoadingBackups = false
    private(set) var hasFinishedLoadingBackups = false
    var textCreateBackup = ""
    var textRenameBackup = ""
    var selectedBackupGroupID: String?
    var alertCreateBackup = false
    var alertRenameBackup = false
    private var backupIDToRename: String?
    private(set) var isLoadingGroups = false
    private(set) var groupLoadFailed = false
    private(set) var isUpdatingGroups = false
    private var permissions: Set<String> = []
    private var isOwner = false

    func configure(_ server: CalagopusServer) {
        permissions = Set(server.permissions)
        isOwner = server.isOwner
    }

    func can(_ permission: String) -> Bool {
        isOwner || permissions.contains("*") || permissions.contains(permission)
    }

    func backups(in groupID: String?) -> [CalagopusServerBackup] {
        backups.filter { $0.backupGroupUuid == groupID }
    }

    var ungroupedBackups: [CalagopusServerBackup] {
        let knownGroups = Set(backupGroups.map(\.uuid))
        return backups.filter { backup in
            guard let groupID = backup.backupGroupUuid else { return true }
            return !knownGroups.contains(groupID)
        }
    }
    
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

    func symbol(for backup: CalagopusServerBackup) -> String {
        backup.kind == .databaseInstance ? Tabs.databases.rawValue : "doc.zipper"
    }

    func kindName(for backup: CalagopusServerBackup) -> String {
        switch backup.kind {
        case .databaseInstance: String(localized: "Database")
        case .unknown(let rawValue): rawValue.capitalized
        case .server, nil: String(localized: "Server")
        }
    }

    func isBrowsable(_ backup: CalagopusServerBackup) -> Bool {
        backup.kind == .server
        && backup.completed != nil
        && backup.isSuccessful
        && backup.isBrowsable
        && backup.deletionStatus == nil
        && !isDeleting(backup)
    }

    func backup(_ uuid: String) -> CalagopusServerBackup? {
        backups.first { $0.uuid == uuid } ?? systemBackups.first { $0.uuid == uuid }
    }

    func backupGroup(_ uuid: String?) -> CalagopusServerBackupGroup? {
        guard let uuid else {
            return nil
        }

        return backupGroups.first { $0.uuid == uuid }
    }

    func isDeleting(_ backup: CalagopusServerBackup) -> Bool {
        deletingBackupIDs.contains(backup.uuid) || backup.deletionStatus == .deleting
    }
    
    func fetchBackups() async {
        guard !isLoadingBackups else {
            return
        }

        isLoadingBackups = true
        
        defer {
            isLoadingBackups = false
            hasFinishedLoadingBackups = true
        }

        async let systemBackups = loadSystemBackups()

        do {
            backups = try await loadBackups()
        } catch {
            SystemAlert.error(error)
        }

        self.systemBackups = await systemBackups
    }

    func fetchBackupGroups() async {
        guard !isLoadingGroups else { return }
        guard can("backup-groups.read") else {
            backupGroups = []
            selectedBackupGroupID = nil
            return
        }
        isLoadingGroups = true
        defer { isLoadingGroups = false }

        do {
            backupGroups = try await CalagopusNet.client().backupGroups(server: id)
                .sorted { $0.order < $1.order }
            groupLoadFailed = false
            if let selectedBackupGroupID, backupGroup(selectedBackupGroupID) == nil {
                self.selectedBackupGroupID = nil
            }
        } catch {
            groupLoadFailed = true
            SystemAlert.error(error)
        }
    }

    func refresh() async {
        await fetchBackupGroups()
        await fetchBackups()
    }

    func saveGroup(_ groupID: String?, name: String, retention: CalagopusBackupRetention) async -> Bool {
        guard !isUpdatingGroups, retention.isValid else { return false }
        isUpdatingGroups = true
        defer { isUpdatingGroups = false }
        do {
            if let groupID {
                try await CalagopusNet.client().updateBackupGroup(server: id, group: groupID, name: name, retention: retention)
            } else {
                _ = try await CalagopusNet.client().createBackupGroup(server: id, name: name, retention: retention)
            }
            await refresh()
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }

    func deleteGroup(_ groupID: String, lockBackups: Bool) async -> Bool {
        guard !isUpdatingGroups else { return false }
        isUpdatingGroups = true
        defer { isUpdatingGroups = false }
        do {
            try await CalagopusNet.client().deleteBackupGroup(server: id, group: groupID, lockBackups: lockBackups)
            if selectedBackupGroupID == groupID { selectedBackupGroupID = nil }
            await refresh()
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }

    func reorderGroup(_ groupID: String, offset: Int) async {
        guard !isUpdatingGroups,
              let index = backupGroups.firstIndex(where: { $0.uuid == groupID }),
              backupGroups.indices.contains(index + offset) else { return }
        isUpdatingGroups = true
        defer { isUpdatingGroups = false }
        var order = backupGroups.map(\.uuid)
        order.swapAt(index, index + offset)
        do {
            try await CalagopusNet.client().reorderBackupGroups(server: id, order: order)
            await fetchBackupGroups()
        } catch {
            SystemAlert.error(error)
        }
    }

    func moveBackup(_ backupID: String, to groupID: String?) async {
        do {
            try await CalagopusNet.client().moveBackup(server: id, backup: backupID, group: groupID)
            await refresh()
        } catch {
            SystemAlert.error(error)
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

    func beginRenaming(_ backup: CalagopusServerBackup) {
        backupIDToRename = backup.uuid
        textRenameBackup = backup.name
        alertRenameBackup = true
    }

    func renameBackup() async {
        let name = textRenameBackup.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let backupIDToRename,
              let backup = backups.first(where: { $0.uuid == backupIDToRename }),
              !name.isEmpty else {
            return
        }

        defer {
            self.backupIDToRename = nil
            textRenameBackup = ""
        }

        guard name != backup.name else {
            return
        }

        do {
            try await CalagopusNet.client().renameBackup(server: id, backup: backupIDToRename, name: name)
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
            await fetchBackupGroups()
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
        await fetchBackupGroups()
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

    private func loadSystemBackups() async -> [CalagopusServerBackup] {
        do {
            return try await CalagopusNet.client().systemBackups(server: id).data
        } catch {
            Logger().error("Failed to load system backups: \(error)")
            return []
        }
    }
}
