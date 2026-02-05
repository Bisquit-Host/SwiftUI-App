import SwiftUI
import Kingfisher

struct VersionChangerTypeLogo: View {
    private let size: CGFloat = 39
    private let cornerRadius: CGFloat = 12
    private let url: URL?
    @State private var failedLoading = false
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        if let url, failedLoading == false {
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
}
