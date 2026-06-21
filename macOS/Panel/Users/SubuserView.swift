import ScrechKit
import Calagopus

struct SubuserView: View {
    @Environment(SubuserVM.self) private var vm
    
    @State private var user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    var body: some View {
        Form {
            SubuserImage(user.image)
            
            Text(user.email)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Subuser2FA(user.totpEnabled)
            
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
        .scrollIndicators(.never)
        .formStyle(.grouped)
        .frame(height: 600)
        .refreshable {
            await vm.userDetails($user)
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
            SubuserView(PreviewProp.userAttributes)
        }
        .darkSchemePreferred()
        .environment(SubuserVM(""))
}
