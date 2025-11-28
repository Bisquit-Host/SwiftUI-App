import SwiftUI

struct SupportMediaViewer: View {
    @State private var vm = SupportMediaViewerVM()
    
    let mediaPath: String
    let accessToken: String
    var onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = vm.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
            } else if vm.isLoading {
                ProgressView()
                    .tint(.white)
            }
        }
        .navigationTitle(mediaPath)
        .toolbarTitleDisplayMode(.inline)
        .task {
            await vm.loadMedia(mediaPath: mediaPath, accessToken: accessToken)
        }
        .toolbar {
            Button(role: .destructive) {
                onClose()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}

#Preview {
    SupportMediaViewer(mediaPath: "media/example.png", accessToken: "") {}
        .darkSchemePreferred()
}
