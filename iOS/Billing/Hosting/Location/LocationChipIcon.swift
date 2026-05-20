import SwiftUI
import Kingfisher

struct LocationChipIcon: View {
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
                }
                .scaledToFill()
                .frame(width: 28, height: 18)
                .clipShape(.rect(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.primary.opacity(0.08), lineWidth: 1)
                }
        }
    }
}

//#Preview {
//    LocationChipIcon()
//        .darkSchemePreferred()
//}
