import SwiftUI

struct SocialButton: View {
    let provider: String
    let img: ImageResource
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SocialButtonImage(img)
        }
    }
}

//#Preview {
//    LoginViewSocialButton()
//        .darkSchemePreferred()
//}
