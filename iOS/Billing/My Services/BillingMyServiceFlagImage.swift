import SwiftUI

struct BillingMyServiceFlagImage: View {
    private let urlString: String?
    
    init(_ urlString: String?) {
        self.urlString = urlString
    }
    
    var body: some View {
        if let urlString, let url = URL(string: urlString) {
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

