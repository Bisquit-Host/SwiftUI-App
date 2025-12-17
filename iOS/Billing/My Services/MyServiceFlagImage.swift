import SwiftUI

struct MyServiceFlagImage: View {
    private let flagURL: String?
    
    init(_ flagURL: String?) {
        self.flagURL = flagURL
    }
    
    var body: some View {
        if let flagURL, let url = URL(string: flagURL) {
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
