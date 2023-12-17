import Observation
import PteroNet

@Observable
final class SftpVM {
    var username = ""
    
    func accountDetails() {
        accountDetailsAPI { [self] result in
            switch result {
            case .success(let model):
                if let model {
                    username = model.attributes.username
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
