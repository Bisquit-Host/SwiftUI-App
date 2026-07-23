import SwiftUI
import Kingfisher

struct MinecraftCatalogIcon: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    
    private let url: URL?
    private let placeholderSystemImage: String
    
    init(_ url: URL?, placeholderSystemImage: String) {
        self.url = url
        self.placeholderSystemImage = placeholderSystemImage
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
        .frame(44)
        .clipShape(.rect(cornerRadius: 8))
    }
    
    private var shouldUseAnimatedImage: Bool {
        guard !reduceMotion, bigAssAnimations else {
            return false
        }
        
        guard let url else { return false }
        
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
