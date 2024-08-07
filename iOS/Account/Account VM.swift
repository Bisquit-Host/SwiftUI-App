import SwiftUI
import CoreImage.CIFilterBuiltins
import PteroNet

@Observable
final class AccountVM {
    var account: AccountAttributes? = nil
    var qrCodeUrl = ""
    
    func fetch() {
        accountDetailsAPI { [self] result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    account = model
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func twoFaDetails() {
        twoFaDetailtsAPI { [self] result in
            switch result {
            case .success(let model):
                if let model = model?.data.imageUrlData {
                    qrCodeUrl = model
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
