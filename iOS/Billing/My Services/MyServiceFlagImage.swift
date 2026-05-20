import SwiftUI
import Kingfisher

struct MyServiceFlagImage: View {
    private let url: URL?
    
    init(_ flagURL: String?) {
        self.url = URL(string: flagURL ?? "")
    }
    
    var body: some View {
        if let url {
            KFImage(url)
                .resizable()
                .placeholder {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 20, height: 14)
                }
                .frame(width: 20, height: 14)
                .clipShape(.rect(cornerRadius: 2))
        }
    }
}
