import Calagopus

@Observable
final class BackupCardVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var showSafari = false
    var url = ""
    
    func downloadBackup(_ uuid: String) async {
        do {
            url = try await backupDownloadAPI(id, uuid: uuid)
            self.showSafari = true
        } catch {
            SystemAlert.error(error)
        }
    }
}
