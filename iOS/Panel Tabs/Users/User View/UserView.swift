import ScrechKit
import PteroNet

#if canImport(MailCover)
import MailCover
#endif

struct UserView: View {
    @Environment(UsersVM.self) private var vm
    
#if !os(tvOS) && !os(watchOS)
    @State private var contacts = ContactManager()
#endif
    
    @State private var user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    @State private var mailCover = false
    
    var body: some View {
        NavigationStack {
            List {
#if !os(iOS)
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
#endif
                Section {
                    User2FA(user.twoFaEnabled)
                    
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
                }
                
                PermissionList($user)
                    .environment(vm)
            }
            .navigationTitle(user.username)
#if os(iOS)
            .navigationSubtitle(user.email)
#endif
            .toolbarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
#if canImport(MailCover)
            .mailCover($mailCover, recipients: [user.email])
#endif
            .refreshable {
                await vm.userDetails($user)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    UserImage(user.image)
                }
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Copy", systemImage: "doc.on.doc") {
#if os(macOS)
                            NSPasteboard.general.setString(user.email, forType: .string)
#else
                            Pasteboard.copy(user.email)
                            SystemAlert.copied()
#endif
                        }
#if canImport(MailCover)
                        Button("Send email", systemImage: "envelope") {
                            mailCover = true
                        }
#endif
                        Button("Save to Contacts", systemImage: "person.crop.circle.badge.plus") {
                            contacts.saveContact(user.email)
                        }
                        
                        ShareLink(item: user.email)
                    } label: {
                        Image(systemName: "envelope")
                    }
                }
#endif
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
            UserView(PreviewProp.userAttributes)
        }
        .darkSchemePreferred()
        .environment(UsersVM(""))
}
