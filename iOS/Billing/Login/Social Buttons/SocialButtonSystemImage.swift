import SwiftUI

struct SocialButtonSystemImage: View {
    private let systemImage: String
    
    init(_ systemImage: String) {
        self.systemImage = systemImage
    }
    
    var body: some View {
        let image = Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .frame(32)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
        
#if os(visionOS)
        image
#else
        image
            .glassEffect(in: .capsule)
#endif
    }
}

#Preview {
    SocialButtonSystemImage("apple.logo")
}
