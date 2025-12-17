import SwiftUI

struct LocationChipIcon: View {
    private let flagURL: String?
    
    init(_ flagURL: String?) {
        self.flagURL = flagURL
    }
    
    var body: some View {
        if let flagURL, let url = URL(string: flagURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.15)
            }
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
