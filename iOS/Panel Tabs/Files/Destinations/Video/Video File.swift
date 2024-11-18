import SwiftUI
import AVKit

struct VideoFile: View {
    @State private var vm: VideoFileVM
    
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
        
        self.vm = VideoFileVM(id, root: root, name: name)
    }
    
    var body: some View {
        VStack {
            if let url = vm.localVideoUrl {
#if os(watchOS)
                WatchVideoPlayer(url)
#else
                VideoPlayerView(url)
                    .blur(radius: vm.isSensitive ? 10 : 0)
#endif
            }
        }
        .navigationTitle(name)
        .task {
            vm.fetchVideoUrl(name, root: root)
        }
        .toolbar {
            if let url = vm.localVideoUrl {
                ShareLink(item: url)
            }
            
            if vm.isSensitive {
                Button {
                    withAnimation {
                        vm.isSensitive = false
                    }
                } label: {
                    Image(systemName: "eye.slash")
                }
            }
        }
    }
}

#Preview {
    VideoFile("id", root: "", name: "Preview")
}
