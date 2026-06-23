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
            url = try await CalagopusNet.client().backupDownloadURL(server: id, backup: uuid)
            self.showSafari = true
        } catch {
            SystemAlert.error(error)
        }
    }
}
