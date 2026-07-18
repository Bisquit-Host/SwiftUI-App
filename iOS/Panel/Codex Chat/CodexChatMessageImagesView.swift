import SwiftUI

struct CodexChatMessageImagesView: View {
    let images: [CodexChatMessageImage]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(images) {
                CodexChatMessageImageView(image: $0)
            }
        }
        .containerRelativeFrame(.horizontal) { length, _ in
            length * 0.8
        }
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: images.count > 1 ? 2 : 1)
    }
}
