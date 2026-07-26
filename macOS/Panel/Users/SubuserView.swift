import ScrechKit
import Calagopus

struct SubuserView: View {
    @Environment(SubuserVM.self) private var vm
    
    @State private var user: CalagopusServerSubuser
    
    init(_ user: CalagopusServerSubuser) {
        self.user = user
    }
    
    var body: some View {
        Form {
            SubuserImage(user.user.avatar ?? "")
            
            Subuser2FA(user.user.totpEnabled)
            
            HStack {
                Text("Member since")
                
                Spacer()
                
                VStack {
                    Text(formatISO(user.created))
                    
                    Text(timeSinceISO(user.created))
                        .footnote()
                        .secondary()
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            
            PermissionList($user)
                .environment(vm)
        }
        .navigationTitle(user.user.username)
        .scrollIndicators(.never)
        .formStyle(.grouped)
        .frame(height: 600)
        .refreshable {
            await vm.userDetails($user)
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            SubuserView(PreviewProp.userAttributes)
        }
        .darkSchemePreferred()
        .environment(SubuserVM(""))
}
