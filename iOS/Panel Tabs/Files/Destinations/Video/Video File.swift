import SwiftUI
import AVKit

struct VideoFile: View {
    @State private var vm: VideoFileVM
    @EnvironmentObject private var fileVm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.name = name
        self.path = path
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
            await vm.fetchVideoUrl(name, root: path)
        }
        .toolbar {
#if os(tvOS)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
#endif
            
#if os(iOS)
            if vm.isSensitive {
                Button {
                    withAnimation {
                        vm.isSensitive = false
                    }
                } label: {
                    Image(systemName: "eye.slash")
                }
            }
            
            Menu {
                if let url = vm.localVideoUrl {
                    ShareLink(item: url)
                        .transition(.identity)
                } else {
                    ShareLink(item: name)
                        .disabled(vm.localVideoUrl == nil)
                }
                
                Section {
                    Button(role: .destructive) {
                        Task {
                            await fileVm.deleteFile(name, at: path) {
                                dismiss()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
#endif
        }
    }
}

#Preview {
    VideoFile("id", name: "Preview", at: "")
        .environmentObject(FileTabVM(""))
}
