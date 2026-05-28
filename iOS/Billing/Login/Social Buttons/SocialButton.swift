import ScrechKit

struct SocialButton: View {
    let provider: String
    let img: ImageResource?
    let systemImage: String?
    let isLastUsed: Bool
    let action: () -> Void
    
    init(provider: String, img: ImageResource, isLastUsed: Bool, action: @escaping () -> Void) {
        self.provider = provider
        self.img = img
        self.systemImage = nil
        self.isLastUsed = isLastUsed
        self.action = action
    }
    
    init(provider: String, systemImage: String, isLastUsed: Bool, action: @escaping () -> Void) {
        self.provider = provider
        self.img = nil
        self.systemImage = systemImage
        self.isLastUsed = isLastUsed
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if let img {
                SocialButtonImage(img)
            } else if let systemImage {
                SocialButtonSystemImage(systemImage)
            }
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
