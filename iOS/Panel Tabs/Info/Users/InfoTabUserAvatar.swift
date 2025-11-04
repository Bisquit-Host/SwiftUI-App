import SwiftUI
import Kingfisher

struct InfoTabUserAvatar: View {
    private let img: String
    
    init(_ img: String) {
        self.img = img
    }
    
    var body: some View {
        if let url = URL(string: img) {
            KFImage(url)
                .resizable()
                .frame(32)
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
        }
    }
}

#Preview {
    InfoTabUserAvatar("https://bisquit.host/_ipx/s_80x80/logo.webp")
        .darkSchemePreferred()
}
