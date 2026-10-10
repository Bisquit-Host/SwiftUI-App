import SwiftUI

struct LogCardImage: View {
    private let imageURL: URL?
    private let username: String?
    
    init(_ image: String?, username: String? = nil) {
        self.imageURL = LogVM.actorImageURL(image)
        self.username = username
    }
    
    private let size = 32.0
    
    var body: some View {
        if let username {
            SubuserImage(imageURL?.absoluteString, username: username, size: size)
        } else {
            Image(systemName: "pc")
                .resizable()
                .scaledToFit()
                .frame(size)
        }
    }
}

#Preview {
    HStack {
        LogCardImage("https://bisquit.host/_ipx/s_80x80/logo.webp", username: "Example User")

        LogCardImage("", username: "Example User")

        LogCardImage(nil)
    }
    .darkSchemePreferred()
}
