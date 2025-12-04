import SwiftUI
struct AuthSocialButtonImage: View {
    private let img: ImageResource
    
    init(_ img: ImageResource) {
        self.img = img
    }
    
    private var avgColor: UIColor? {
        UIImage(resource: img).findAverageColor(.simple)
    }
    
    var body: some View {
        if let avgColor {
            Image(img)
                .resizable()
                .frame(32)
                .clipShape(.circle)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(Color(avgColor)), in: .capsule)
        } else {
            Image(img)
                .resizable()
                .frame(32)
                .clipShape(.circle)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .glassEffect(in: .capsule)
        }
    }
}
