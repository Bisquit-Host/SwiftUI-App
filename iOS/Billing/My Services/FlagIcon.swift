import SwiftUI
import Kingfisher

struct FlagIcon: View {
    private let url: URL?
    
    init(_ flagURL: String?) {
        self.url = URL(string: flagURL ?? "")
    }
    
    var body: some View {
        if let url {
            KFImage(url)
                .resizable()
                .placeholder {
                    Color.gray.opacity(0.15)
                        .frame(width: 24, height: 16)
                        .clipShape(.rect(cornerRadius: 3))
                }
                .frame(width: 24, height: 16)
                .clipShape(.rect(cornerRadius: 3))
        }
    }
}
