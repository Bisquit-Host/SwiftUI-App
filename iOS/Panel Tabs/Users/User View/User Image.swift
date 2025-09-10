import SwiftUI
import Kingfisher

struct UserImage: View {
    private let image: String
    
    init(_ image: String) {
        self.image = image
    }
    
    var body: some View {
        KFImage(URL(string: image))
            .resizable()
            .frame(32)
            .clipShape(.circle)
    }
}

#Preview {
    UserImage("https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png")
}
