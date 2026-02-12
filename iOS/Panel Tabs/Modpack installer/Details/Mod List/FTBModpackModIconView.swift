import SwiftUI
import Kingfisher

struct FTBModpackModIconView: View {
    private let iconURL: URL?
    
    init(_ iconURL: URL?) {
        self.iconURL = iconURL
    }
    
    var body: some View {
        Group {
            if let iconURL {
                KFImage(iconURL)
                    .placeholder {
                        placeholderIcon
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderIcon
            }
        }
        .frame(28)
        .clipShape(.rect(cornerRadius: 8))
    }
    
    private var placeholderIcon: some View {
        Image(systemName: "shippingbox.fill")
            .secondary()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
    }
}
