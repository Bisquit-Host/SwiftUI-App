import SwiftUI

struct AccountSettingsHeader: View {
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var avatarPreview: UIImage?
    
    var body: some View {
        HStack(spacing: 20) {
            avatarImage(for: user)
                .overlay(alignment: .topTrailing) {
                    AccountSettingsAvatarPicker($avatarPreview)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .subheadline(.semibold)
                    .lineLimit(2)
                
                Text(user.email)
                    .footnote()
                    .secondary()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func avatarImage(for user: BillingUser) -> some View {
        let size = 72.0
        
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
                        AccountSettingsAvatarPlaceholderInitial(user)
                        
                    @unknown default:
                        AccountSettingsAvatarPlaceholderInitial(user)
                    }
                }
            } else {
                AccountSettingsAvatarPlaceholderInitial(user)
            }
        }
        .animation(.default, value: avatarPreview)
        .frame(size)
        .clipShape(.circle)
        .overlay {
            Circle()
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
    }
}
