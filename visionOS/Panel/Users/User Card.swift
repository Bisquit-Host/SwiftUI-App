import SwiftUI
import PteroNet

struct UserCard: View {
    @Environment(UsersVM.self) private var vm
    
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
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
//            Image(systemName: "")
        }
    }
}

//#Preview {
//    UserCard()
//}
