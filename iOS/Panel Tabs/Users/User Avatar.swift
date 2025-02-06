import SwiftUI
import Kingfisher

struct UserAvatar: View {
    private let image: String
    
    init(_ image: String) {
        self.image = image
    }
    
    var body: some View {
        Section {
            HStack {
                KFImage(stringToUrl(image))
                    .resizable()
                    .frame(width: 160, height: 160)
                    .clipShape(.circle)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        UserAvatar("https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png")
    }
}
