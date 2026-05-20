import SwiftUI
import Kingfisher

struct FTBModpackModIconView: View {
    private let iconSize = 28.0
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
        .frame(width: iconSize, height: iconSize)
        .clipShape(.rect(cornerRadius: 8))
    }
    
    private var placeholderIcon: some View {
        ZStack {
            Rectangle()
                .fill(.thinMaterial)
            
            Image(systemName: "shippingbox.fill")
                .secondary()
        }
    }
}
