import SwiftUI
import Calagopus

struct UserCard: View {
    private let user: CalagopusServerSubuser
    
    init(_ user: CalagopusServerSubuser) {
        self.user = user
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.user.username)
                
                Text(user.user.uuid)
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
