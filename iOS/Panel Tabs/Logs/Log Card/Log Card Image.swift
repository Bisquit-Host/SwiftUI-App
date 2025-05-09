import SwiftUI
import Kingfisher

struct LogCardImage: View {
    private let image: String?
    
    init(_ image: String?) {
        self.image = image
    }
    
    private var size: CGFloat {
#if os(tvOS)
        64
#else
        32
#endif
    }
    
    var body: some View {
        if let image {
            KFImage(URL(string: image))
                .resizable()
                .frame(32)
                .clipShape(.circle)
        } else {
            Image(systemName: "pc")
                .resizable()
                .scaledToFit()
                .frame(32)
        }
    }
}

//#Preview {
//    LogCardImage()
//}
