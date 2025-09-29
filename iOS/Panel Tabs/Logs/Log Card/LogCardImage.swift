import SwiftUI
import Kingfisher

struct LogCardImage: View {
    private let image: String?
    
    init(_ image: String?) {
        self.image = image
    }
    
    private let size = System.isTV ? 64.0 : 32
    
    var body: some View {
        if let image {
            KFImage(URL(string: image))
                .resizable()
                .frame(size)
                .clipShape(.circle)
        } else {
            Image(systemName: "pc")
                .resizable()
                .scaledToFit()
                .frame(size)
        }
    }
}

#Preview {
    LogCardImage("https://bisquit.host/_ipx/s_80x80/logo.webp")
        .darkSchemePreferred()
}
