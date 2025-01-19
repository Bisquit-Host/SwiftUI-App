import SwiftUI
import Kingfisher

struct InfoTabBackground: View {
    @Environment(\.colorScheme) private var scheme
    
    private var image: String {
        scheme == .light ? "light_background_info" : "dark_background_stats"
    }
    
    var body: some View {
        KFImage(getImageUrl(image))
            .resizable()
            .fade(duration: 0.25)
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    InfoTabBackground()
}
