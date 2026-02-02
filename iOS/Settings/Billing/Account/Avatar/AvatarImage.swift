import SwiftUI

struct AvatarImage: View {
    @Binding private var avatarPreview: UIImage?
    private let user: BillingUser
    
    init(_ avatarPreview: Binding<UIImage?>, for user: BillingUser) {
        _avatarPreview = avatarPreview
        self.user = user
    }
    
    var body: some View {
        ZStack {
            if let avatarPreview {
                Image(uiImage: avatarPreview)
                    .resizable()
                    .scaledToFill()
                
            } else if let avatar = user.avatar, let url = URL(string: avatar) {
                AsyncImage(url: url) {
                    switch $0 {
                    case .empty:
                        ProgressView()
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure:
                        AvatarInitialPlaceholder(user)
                        
                    @unknown default:
                        AvatarInitialPlaceholder(user)
                    }
                }
            } else {
                AvatarInitialPlaceholder(user)
            }
        }
        .animation(.default, value: avatarPreview)
        .frame(72)
        .clipShape(.circle)
        .overlay {
            Circle()
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            AvatarPicker($avatarPreview)
        }
    }
}
