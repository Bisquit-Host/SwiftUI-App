import SwiftUI

struct BillingLoginSocialButton: View {
    private let provider: String
    private let img: ImageResource
    private let isLoading: Bool
    private let action: () -> Void
    
    init(_ provider: String, img: ImageResource, isLoading: Bool, action: @escaping () -> Void) {
        self.provider = provider
        self.img = img
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
            } else {
                AuthSocialButtonImage(img)
            }
        }
        .disabled(isLoading)
    }
}

//#Preview {
//    BillingLoginSocialButton()
//        .darkSchemePreferred()
//}
