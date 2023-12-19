import ScrechKit
import Kingfisher
import PteroNet

struct UserView: View {
    @Environment(UsersVM.self) private var vm
    
    @State private var user: UserListAttributes
    
    init(_ user: UserListAttributes) {
        self.user = user
    }
                
    var body: some View {
        NavigationView {
            List {
                UserAvatar(user.image)
#if os(watchOS)
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
#else
                UserEmail(user.email)
#endif
                HStack {
                    Text("2FA")
                    
                    Spacer()
                    
                    if user.twoFaEnabled {
                        Text("Enabled \(Image(systemName: "lock.fill"))")
                            .foregroundStyle(.green)
                    } else {
                        Text("Disabled")
                            .foregroundStyle(.red)
                    }
                }
                
                HStack {
                    Text("Member since")
                    
                    Spacer()
                    
                    VStack {
                        Text(formatISO(user.createdAt))
                        
                        Text(timeSinceISO(user.createdAt))
                            .footnote()
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                PermissionList($user)
                    .environment(vm)
            }
            .refreshable {
                vm.userDetails($user)
            }
            .navigationTitle(user.username)
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
        }
    }
    
    func removePrefix(_ string: String) -> String {
        let components = string.split(separator: ".")
        
        guard components.count > 1 else {
            return string
        }
        
        return components[1...].joined(separator: ".")
    }
}

#Preview {
    Text("Preview")
        .sheet(.constant(true)) {
            UserView(
                sampleJSON(.userAttributes)
            )
        }
        .environment(UsersVM(""))
}
