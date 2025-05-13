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
                .frame(size)
                .clipShape(.circle)
        } else {
            Image(systemName: "pc")
                .resizable()
                .scaledToFit()
                .frame(size)
        }
    }
}

//#Preview {
//    LogCardImage()
//}
