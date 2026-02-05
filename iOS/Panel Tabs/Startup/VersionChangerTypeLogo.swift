import SwiftUI
import Kingfisher

struct VersionChangerTypeLogo: View {
    private let url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        if let url {
            KFImage(url)
                .resizable()
                .placeholder {
                    ProgressView()
                        .frame(26)
                }
                .scaledToFill()
                .frame(26)
                .clipShape(.rect(cornerRadius: 8))
        } else {
            GlassyIcon("shippingbox.fill", tint: .indigo)
        }
    }
}
