import SwiftUI

struct BillingLoginSocialButton: View {
    let provider: String
    let img: ImageResource
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            AuthSocialButtonImage(img)
        }
    }
}

//#Preview {
//    BillingLoginSocialButton()
//        .darkSchemePreferred()
//}
