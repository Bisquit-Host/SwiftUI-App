import SwiftUI

struct SupportMedia: View {
    @State private var vm = TicketMediaVM()
    
    let mediaPath: String
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
            await vm.loadMedia(mediaPath: mediaPath)
        }
        .toolbar {
            Button(role: .destructive, action: onClose) {
                Image(systemName: "xmark")
            }
        }
    }
}

#Preview {
    SupportMedia(mediaPath: "media/example.png") {}
        .darkSchemePreferred()
}
