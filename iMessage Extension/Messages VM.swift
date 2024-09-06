import SwiftUI
import Messages

@Observable
final class MessagesVM {
    var message = "Hello from ViewModel!"
    
    func updateMessage(newMessage: String) {
        message = newMessage
    }
    
    func sendMessage() {
        guard let conversation = MSMessagesAppViewController().activeConversation else {
            print("Error finding a conversation")
            return
        }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = self.message
        message.layout = layout
        
        print(conversation.description)
        
        conversation.insert(message) { error in
            if let error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}
