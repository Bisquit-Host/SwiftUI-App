import SwiftUI
import Messages
import PteroNet

struct HomeView: View {
    @State private var vm = MessagesVM()
    @State private var viewController: MessagesViewController?
    
    init(viewController: MessagesViewController?) {
        self.viewController = viewController
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
        guard let conversation = viewController?.conversation else {
            print("No active conversation")
            return
        }
        
        // Create a message with text content
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = text
        layout.subcaption = text
        message.layout = layout
        
        // Insert the message into the active conversation
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
