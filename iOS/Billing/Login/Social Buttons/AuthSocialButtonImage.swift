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
        let image = Image(img)
            .resizable()
            .frame(32)
            .clipShape(.circle)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
#if os(visionOS)
        image
#else
        if let avgColor {
            image
                .glassEffect(.regular.tint(Color(avgColor)), in: .capsule)
        } else {
            image
                .glassEffect(in: .capsule)
        }
#endif
    }
}
