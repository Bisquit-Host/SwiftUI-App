import PteroNet

@Observable
final class BackupCardVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var showSafari = false
    var url = ""
    
    func downloadBackup(_ uuid: String) {
        backupDownloadAPI(id, uuid: uuid) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    self.url = model.url
                    self.showSafari = true
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
