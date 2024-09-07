import ScrechKit
import SafariCover
import MailCover

struct Support: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var sheetGuide = false
    @State private var showMailCover = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    buttonApi
                    buttonWiki
                    buttonSupportApp
                    buttonSupportHosting
                }
                .listRowBackground(settings.transparentList ? .clear : Color.list)
                
                Section("Contact") {
                    buttonTelegram
                    buttonMail
                }
                .listRowBackground(settings.transparentList ? .clear : Color.list)
            }
            .navigationTitle("Support")
            .toolbarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.large, .medium])
        .scrollContentBackground(settings.transparentSheet ? .hidden : .visible)
        .presentationBackground(settings.transparentSheet ? .ultraThinMaterial : .regular)
        .mailCover(
            $showMailCover,
            message: "Hello there! \n",
            subject: "Bisquit.Host Feedback",
            recipients: ["sergei_saliukov@icloud.com"]
        )
        .sheet($sheetGuide) {
            Guide()
        }
    }
    
    var buttonWiki: some View {
        SafariButton("https://wiki.bisquit.host") {
            ListButton("Wiki / FAQ",
                       icon: "books.vertical",
                       actionIcon: "link",
                       color: .blue
            )
        }
    }
    
    var buttonSupportApp: some View {
        SafariButton("https://topscrech.dev/app/support") {
            ListButton("App Support",
                       icon: "questionmark.bubble.fill",
                       actionIcon: "link",
                       color: .purple
            )
        }
    }
    
#warning("Code style")
    var buttonSupportHosting: some View {
        SafariButton("https://my.bisquit.host/contact.php") {
            ListButton("Hosting Support",
                       icon: "questionmark.bubble.fill",
                       actionIcon: "link",
                       color: .purple
            )
        }
    }
    
    var buttonApi: some View {
        ListButton("Where to find the API-key?",
                   icon: "key.fill",
                   actionIcon: "chevron.forward"
        ) {
            sheetGuide = true
        }
    }
    
    var buttonMail: some View {
        ListButton("Mail",
                   icon: "envelope.fill",
                   actionIcon: "envelope"
        ) {
            showMailCover = true
        }
    }
    
    var buttonTelegram: some View {
        ListButton("Telegram Chat", icon: "paperplane.fill", actionIcon: "link") {
            openSafari("https://t.me/bisquit_host_chat")
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            Support()
        }
        .environmentObject(SettingsStorage())
}
