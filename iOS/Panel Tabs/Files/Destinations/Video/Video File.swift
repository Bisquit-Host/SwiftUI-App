import SwiftUI
import AVKit

struct VideoFile: View {
    @State private var vm: VideoFileVM
    @EnvironmentObject private var fileVm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
        
        self.vm = VideoFileVM(id, root: path, name: name)
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
            } else {
                ProgressView()
            }
        }
        .navigationTitle(name)
        .task {
            vm.fetchVideoUrl(name, root: path)
        }
        .toolbar {
            if vm.isSensitive {
                Button {
                    withAnimation {
                        vm.isSensitive = false
                    }
                } label: {
                    Image(systemName: "eye.slash")
                }
            }
            
#if !os(watchOS)
            Menu {
#if !os(tvOS)
                if let url = vm.localVideoUrl {
                    ShareLink(item: url)
                        .transition(.identity)
                } else {
                    ShareLink(item: name)
                        .disabled(vm.localVideoUrl == nil)
                }
#endif
                Section {
                    Button(role: .destructive) {
                        fileVm.deleteFile(name, at: path) {
                            dismiss()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
#endif
        }
    }
}

#Preview {
    VideoFile("id", path: "", name: "Preview")
        .environmentObject(FileTabVM(""))
}
