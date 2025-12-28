import SwiftUI

struct FlagIcon: View {
    private let url: URL?
    
    init(_ flagURL: String?) {
        self.url = URL(string: flagURL ?? "")
    }
    
    var body: some View {
        if let url {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(width: 24, height: 16)
                    .clipShape(.rect(cornerRadius: 3))
            } placeholder: {
                Color.gray.opacity(0.15)
                    .frame(width: 24, height: 16)
                    .clipShape(.rect(cornerRadius: 3))
            }
        }
    }
}
