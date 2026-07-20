import SwiftUI

struct CodexChatImagePreviews: View {
    @Environment(CodexChatVM.self) private var vm

    let disabled: Bool

    var body: some View {
        if !vm.pendingImages.isEmpty {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(vm.pendingImages) { image in
                        ZStack(alignment: .topTrailing) {
                            if let cgImage = codexChatCGImage(from: image.data) {
                                Image(decorative: cgImage, scale: 1)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(.rect(cornerRadius: 8))
                            }

                            Button("Remove image", systemImage: "xmark.circle.fill") {
                                vm.removeImage(image)
                            }
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.white, .black.opacity(0.7))
                            .disabled(disabled)
                        }
                        .accessibilityLabel(image.name)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
