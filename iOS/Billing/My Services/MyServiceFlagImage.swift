import SwiftUI

struct MyServiceFlagImage: View {
    private let url: URL?
    
    init(_ flagURL: String?) {
        self.url = URL(string: flagURL ?? "")
    }
    
    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 20, height: 14)
                        .clipShape(.rect(cornerRadius: 2))
                    
                default:
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 20, height: 14)
                }
            }
        }
    }
}
