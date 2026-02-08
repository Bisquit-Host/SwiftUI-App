import SwiftUI
import Kingfisher

struct VersionChangerTypeLogo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private let url: URL?
    @State private var failedLoading = false
    
    init(url: URL?, size: CGFloat = 39) {
        self.url = url
        self.size = size
        self.cornerRadius = max(6, size * 0.3)
    }
    
    var body: some View {
        if let url, failedLoading == false {
            Group {
                if shouldUseAnimatedImage(url) && !reduceMotion && bigAssAnimations {
                    KFAnimatedImage(url)
                        .onFailure { _ in
                            failedLoading = true
                        }
                        .placeholder {
                            ProgressView()
                                .frame(size)
                        }
                        .aspectRatio(contentMode: .fill)
                } else {
                    KFImage(url)
                        .resizable()
                        .onFailure { _ in
                            failedLoading = true
                        }
                        .placeholder {
                            ProgressView()
                                .frame(size)
                        }
                        .scaledToFill()
                }
            }
            .frame(size)
            .clipShape(.rect(cornerRadius: cornerRadius))
        } else {
            Image(systemName: "shippingbox.fill")
                .frame(size)
                .foregroundStyle(.indigo)
#if !os(visionOS)
                .glassEffect(.regular.tint(.indigo.opacity(0.15)), in: .rect(cornerRadius: cornerRadius))
#endif
        }
    }

    private func shouldUseAnimatedImage(_ url: URL) -> Bool {
        if url.pathExtension.caseInsensitiveCompare("gif") == .orderedSame {
            return true
        }

        let lowercasedURL = url.absoluteString.lowercased()

        return lowercasedURL.hasSuffix(".gif")
            || lowercasedURL.contains(".gif?")
            || lowercasedURL.contains("format=gif")
    }
}
