import SwiftUI

struct CodexChatMessageImageView: View {
    let image: CodexChatMessageImage

    @State private var cgImage: CGImage?
    @State private var loadingFailed = false

    var body: some View {
        Group {
            if let cgImage {
                Image(decorative: cgImage, scale: 1)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 24))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else if loadingFailed {
                ContentUnavailableView("Image unavailable", systemImage: "photo.badge.exclamationmark")
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minHeight: 80, maxHeight: 240, alignment: .trailing)
        .task(id: image.url) {
            do {
                let data = try await image.loadData()
                cgImage = codexChatCGImage(from: data)
                loadingFailed = cgImage == nil
            } catch {
                loadingFailed = true
            }
        }
        .accessibilityLabel(image.name)
    }
}
