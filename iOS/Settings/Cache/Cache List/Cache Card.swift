import SwiftUI

struct CacheCard: View {
    private let cache: CachedImage
    
    init(_ cache: CachedImage) {
        self.cache = cache
    }
    
    var body: some View {
        HStack {
            Image(uiImage: cache.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(100)
                .clipShape(.rect(cornerRadius: 16))
            
            Spacer()
            
            Text(cache.size)
                .secondary()
        }
    }
}

//#Preview {
//    CacheCard()
//}
