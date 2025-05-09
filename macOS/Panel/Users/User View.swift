import ScrechKit
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
                
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
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
#warning("macOS")
                //                PermissionList($user)
                //                    .environment(vm)
            }
            .refreshable {
                vm.userDetails($user)
            }
            .navigationTitle(user.username)
            .toolbarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
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
