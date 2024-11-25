import ScrechKit
import SafariCover

struct Support: View {
    @EnvironmentObject private var settings: ValueStorage
    
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
            .foregroundStyle(.primary)
            .navigationTitle("Support")
            .toolbarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.large, .medium])
        .scrollContentBackground(settings.transparentSheet ? .hidden : .visible)
        .presentationBackground(settings.transparentSheet ? .ultraThinMaterial : .regular)
        .sheet($sheetGuide) {
            Guide()
        }
        .mailCover(
            $showMailCover,
            message: "Hello there! \n",
            subject: "Bisquit.Host Feedback",
            recipients: ["sergei_saliukov@icloud.com"]
        )
    }
    
    private var buttonApi: some View {
        Button {
            sheetGuide = true
        } label: {
            HStack {
                Text("Where to find the API-key?")
                
                Spacer()
                
                Image(systemName: "key.fill")
                    .secondary()
            }
        }
    }
    
    private var buttonWiki: some View {
        SafariButton("https://wiki.bisquit.host") {
            HStack {
                Text("Wiki / FAQ")
                
                Spacer()
                
                Image(systemName: "link")
                    .secondary()
            }
        }
    }
    
    private var buttonSupportApp: some View {
        SafariButton("https://topscrech.dev/app/support") {
            HStack {
                Text("App Support")
                
                Spacer()
                
                Image(systemName: "link")
                    .secondary()
            }
        }
    }
    
    private var buttonSupportHosting: some View {
        SafariButton("https://my.bisquit.host/contact.php") {
            HStack {
                Text("Hosting Support")
                
                Spacer()
                
                Image(systemName: "link")
                    .secondary()
            }
        }
    }
    
    private var buttonTelegram: some View {
        Button {
            openSafari("https://t.me/bisquit_host_chat")
        } label: {
            HStack {
                Text("Telegram Chat")
                
                Spacer()
                
                Image(systemName: "paperplane")
                    .secondary()
            }
        }
    }
    
    private var buttonMail: some View {
        Button {
            showMailCover = true
        } label: {
            HStack {
                Text("Mail")
                
                Spacer()
                
                Image(systemName: "envelope")
                    .secondary()
            }
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            Support()
        }
        .environmentObject(ValueStorage())
}
