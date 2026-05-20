import ScrechKit

struct SocialButton: View {
    let provider: String
    let img: ImageResource
    let isLastUsed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SocialButtonImage(img)
        }
        .overlay(alignment: .bottom) {
            if isLastUsed {
                SocialButtonBadge("Last used")
            }
        }
    }
}

//#Preview {
//    LoginViewSocialButton()
//        .darkSchemePreferred()
//}
