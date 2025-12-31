import SwiftUI

struct AuthSocialButtonImage: View {
    private let img: ImageResource
    
    init(_ img: ImageResource) {
        self.img = img
    }
    
    private var avgColor: UIColor? {
        UIImage(resource: img)
            .findAverageColor()
    }
    
    var body: some View {
        if let avgColor {
            Image(img)
                .resizable()
                .frame(32)
                .clipShape(.circle)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
#if !os(visionOS)
                .glassEffect(.regular.tint(Color(avgColor)), in: .capsule)
#endif
        } else {
            Image(img)
                .resizable()
                .frame(32)
                .clipShape(.circle)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
#if !os(visionOS)
                .glassEffect(in: .capsule)
#endif
        }
    }
}
