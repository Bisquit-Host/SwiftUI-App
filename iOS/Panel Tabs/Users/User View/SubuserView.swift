import ScrechKit
import Calagopus

struct SubuserView: View {
    @Environment(SubuserVM.self) private var vm
    
    @State private var user: CalagopusServerSubuser
    
    init(_ user: CalagopusServerSubuser) {
        self.user = user
    }
    
    var body: some View {
        List {
#if !os(iOS)
            Text(user.user.username)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
#endif
            Section {
                Subuser2FA(user.user.totpEnabled)
                
                HStack {
                    Text("Member since")
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(user.created, format: .dateTime)
                        
                        Text(user.created, style: .relative)
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
        .navigationTitle(user.user.username)
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .refreshable {
            await vm.userDetails($user)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SubuserImage(user.user.avatar ?? "")
            }
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
