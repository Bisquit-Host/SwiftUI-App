import SwiftUI

struct AccountSettingsHeader: View {
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var avatarPreview: UIImage?
    
    var body: some View {
        HStack(spacing: 20) {
            AccountSettingsAvatarImage($avatarPreview, for: user)
            
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
}
