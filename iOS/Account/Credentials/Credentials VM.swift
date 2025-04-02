import PteroNet

@Observable
final class CredentialsVM {
    func updateCredentials(type: UpdateType) {
        credentialsUpdateAPI(type: type) { result in
            switch result {
            case .success(let model):
                print(model)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
