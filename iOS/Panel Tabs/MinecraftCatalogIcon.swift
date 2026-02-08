import SwiftUI
import Kingfisher

struct MinecraftCatalogIcon: View {
    private let url: URL?
    private let placeholderSystemImage: String
    private let size: CGFloat
    private let cornerRadius: CGFloat
    
    init(
        _ url: URL?,
        placeholderSystemImage: String,
        size: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.url = url
        self.placeholderSystemImage = placeholderSystemImage
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if shouldUseAnimatedImage {
                KFAnimatedImage(url)
                    .placeholder {
                        placeholder
                    }
                    .cacheOriginalImage()
                    .aspectRatio(contentMode: .fill)
            } else {
                KFImage(url)
                    .placeholder {
                        placeholder
                    }
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: cornerRadius))
    }
    
    private var shouldUseAnimatedImage: Bool {
        guard let url else {
            return false
        }
        
        if url.pathExtension.caseInsensitiveCompare("gif") == .orderedSame {
            return true
        }
        
        let lowercasedURL = url.absoluteString.lowercased()
        
        return lowercasedURL.hasSuffix(".gif")
        || lowercasedURL.contains(".gif?")
        || lowercasedURL.contains("format=gif")
    }
    
    private var placeholder: some View {
        Image(systemName: placeholderSystemImage)
            .secondary()
    }
}
