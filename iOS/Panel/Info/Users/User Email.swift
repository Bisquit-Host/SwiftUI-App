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
                    UIPasteboard.general.string = email
                    SystemAlert.copied()
                }
                
                MenuButton("Save to Contacts", icon: "person.crop.circle.badge.plus") {
                    contacts.saveContact(email)
                }
                
                ShareLink(item: email)
            } label: {
                Text(email)
            }
        }
        .mailCover($mailCover)
        .task {
            contacts.requestPermission()
        }
    }
}

#Preview {
    List {
        UserEmail("sergei_saliukov@icloud.com")
    }
}
