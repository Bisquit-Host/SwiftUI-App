import SwiftUI
import PteroNet

struct UserCard: View {
    private let user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.username)
                
                Text(user.email)
                    .footnote()
                    .secondary()
            }
            
            Spacer()
            
            //            Image(systemName: "")
        }
    }
}

#Preview {
    UserCard(PreviewProp.userAttributes)
}
