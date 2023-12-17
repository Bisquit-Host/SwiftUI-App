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
                if let model {
                    account = model.attributes
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func twoFaDetails() {
        twoFaDetailtsAPI { [self] result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    qrCodeUrl = model.imageUrlData
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
