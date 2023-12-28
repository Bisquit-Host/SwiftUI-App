import SwiftUI
import Kingfisher

struct InfoTabBackground: View {
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Group {
            if scheme == .light {
                KFImage(getImageUrl("light_background_info"))
                    .resizable()
                    .fade(duration: 0.25)
            } else {
                KFImage(getImageUrl("dark_background_stats"))
                    .resizable()
                    .fade(duration: 0.25)
            }
        }
        .scaledToFill()
        .ignoresSafeArea()
    }
}

#Preview {
    InfoTabBackground()
}
