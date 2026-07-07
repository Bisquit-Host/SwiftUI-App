import ScrechKit

struct SocialButton: View {
    let provider: String
    let img: ImageResource?
    let systemImage: String?
    let isLastUsed: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(provider: String, img: ImageResource, isLastUsed: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.provider = provider
        self.img = img
        self.systemImage = nil
        self.isLastUsed = isLastUsed
        self.isEnabled = isEnabled
        self.action = action
    }
    
    init(provider: String, systemImage: String, isLastUsed: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.provider = provider
        self.img = nil
        self.systemImage = systemImage
        self.isLastUsed = isLastUsed
        self.isEnabled = isEnabled
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
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.3)
        .overlay(alignment: .topTrailing) {
            if isLastUsed, isEnabled {
                SocialButtonBadge()
            }
        }
        .accessibilityHint(isEnabled ? "" : "Unavailable")
    }
}

//#Preview {
//    LoginViewSocialButton()
//        .darkSchemePreferred()
//}
