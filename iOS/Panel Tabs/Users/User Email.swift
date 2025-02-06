import ScrechKit
import MailCover

struct UserEmail: View {
    private let email: String
    
    init(_ email: String) {
        self.email = email
    }
    
    private var contacts = ContactManager()
    
    @State private var mailCover = false
    
    var body: some View {
        HStack {
            Text("E-mail")
            
            Spacer()
            
            Menu {
                MenuButton("Send email", icon: "envelope") {
                    mailCover = true
                }
                
                MenuButton("Copy", icon: "doc.on.doc") {
#if os(macOS)
                    NSPasteboard.general.setString(email, forType: .string)
#else
                    UIPasteboard.general.string = email
                    SystemAlert.copied()
#endif
                }
                
                MenuButton("Save to Contacts", icon: "person.crop.circle.badge.plus") {
                    contacts.saveContact(email)
                }
                
                ShareLink(item: email)
            } label: {
                Text(email)
            }
        }
        .mailCover($mailCover, recipients: [email])
    }
}

#Preview {
    List {
        UserEmail("sergei_saliukov@icloud.com")
    }
}
