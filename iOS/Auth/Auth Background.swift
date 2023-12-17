import SwiftUI
import Kingfisher

struct AuthBackground: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State private var orientation = UIDevice.current.orientation
    
    private var imageUrl: URL {
        if orientation.isLandscape {
            let baseName = colorScheme == .dark ? "gold_dark" : "gold_light"
            return getImageUrl(baseName)
            
        } else {
            let baseName = colorScheme == .dark ? "launch_dark" : "launch_light"
            return getImageUrl(baseName)
        }
    }
    
    var body: some View {
        KFImage(imageUrl)
            .resizable()
            .fade(duration: 0.25)
    }
}
