import ScrechKit
import Kingfisher
import PteroNet

struct UserView: View {
    @Environment(UsersVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    var body: some View {
        NavigationView {
            List {
                UserAvatar(user.image)
#if os(iOS)
                UserEmail(user.email)
                    .listRowBackground(store.transparentList ? .clear : Color.list)
#else
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
#endif
                User2Fa(user.twoFaEnabled)
                    .listRowBackground(store.transparentList ? .clear : Color.list)
                
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
                .listRowBackground(store.transparentList ? .clear : Color.list)
                
                PermissionListView($user)
                    .environment(vm)
            }
            .refreshable {
                vm.userDetails($user)
            }
            .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
            .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
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
