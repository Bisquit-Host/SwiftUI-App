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
                    .transparentSection()
#else
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
#endif
                User2Fa(user.twoFaEnabled)
                    .transparentSection()
                
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
                .transparentSection()
                
                PermissionList($user)
                    .environment(vm)
            }
            .transparentList()
            .navigationTitle(user.username)
            .toolbarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
            .refreshable {
                vm.userDetails($user)
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
