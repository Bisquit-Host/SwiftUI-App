import SwiftUI

struct LoginViewSocialButton: View {
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
//    LoginViewSocialButton()
//        .darkSchemePreferred()
//}
