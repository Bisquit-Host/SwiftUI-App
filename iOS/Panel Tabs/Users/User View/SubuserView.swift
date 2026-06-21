import ScrechKit
import Calagopus

struct SubuserView: View {
    @Environment(SubuserVM.self) private var vm
#if os(iOS)
    @State private var contacts = ContactManager()
#endif
    @State private var user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    var body: some View {
        List {
#if !os(iOS)
            Text(user.email)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
#endif
            Section {
                Subuser2FA(user.totpEnabled)
                
                HStack {
                    Text("Member since")
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(formatISO(user.createdAt))
                        
                        Text(timeSinceISO(user.createdAt))
                            .footnote()
                            .secondary()
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            
            PermissionList($user)
                .environment(vm)
        }
#if !os(tvOS)
        .listSectionSpacing(12) // spacing fix
#endif
        .navigationTitle(user.username)
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .refreshable {
            await vm.userDetails($user)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SubuserImage(user.image)
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
            SubuserView(PreviewProp.userAttributes)
        }
        .darkSchemePreferred()
        .environment(SubuserVM(""))
}
