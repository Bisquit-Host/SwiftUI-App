import ScrechKit
import Kingfisher
import PteroNet

struct UserView: View {
    @Environment(UsersVM.self) private var vm
    
    @State private var user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    var body: some View {
        NavigationView {
            List {
                UserImage(user.image)
#if os(iOS)
                UserEmail(user.email)
#else
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
#endif
                User2Fa(user.twoFaEnabled)
                
                HStack {
                    Text("Member since")
                    
                    Spacer()
                    
                    VStack {
                        Text(formatISO(user.createdAt))
                        
                        Text(timeSinceISO(user.createdAt))
                            .footnote()
                            .secondary()
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                PermissionList($user)
                    .environment(vm)
            }
            .navigationTitle(user.username)
            .toolbarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
            .refreshable {
                await vm.userDetails($user)
            }
        }
    }
    
    private func removePrefix(_ string: String) -> String {
        let components = string.split(separator: ".")
        
        guard components.count > 1 else {
            return string
        }
        
        return components[1...].joined(separator: ".")
    }
}

#Preview {
    Text("Preview")
        .sheet {
            UserView(sampleJSON(.userAttributes))
        }
        .environment(UsersVM(""))
}
