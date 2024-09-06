import SwiftUI
import Messages
import PteroNet

struct HomeView: View {
    @State private var vm = MessagesVM()
    @Binding private var vc: MessagesViewController?
    
    init(_ vc: Binding<MessagesViewController?>) {
        _vc = vc
    }
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            if let apiKey = Keychain.load(key: "selectedApiKey") {
                Text("Selected API Key: \(apiKey.prefix(6))")
            }
            
            Button("Test") {
                sendMessage("r2f")
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        guard let conversation = vc?.conversation else {
            print("No active conversation")
            return
        }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "text"
        layout.subcaption = "text"
        layout.image = UIImage(named: "artwork")
        layout.imageTitle = "Luza"
        layout.imageSubtitle = "Flufa"
        layout.trailingCaption = "11"
        layout.trailingSubcaption = "22"
        message.layout = layout
        
        conversation.insert(message)
        
        conversation.insert(message) { error in
            if let error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
