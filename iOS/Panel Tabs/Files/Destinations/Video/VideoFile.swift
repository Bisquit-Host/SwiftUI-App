import ScrechKit
import AVKit

struct VideoFile: View {
    @State private var vm: VideoFileVM
    @EnvironmentObject private var fileVM: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.name = name
        self.path = path
        vm = VideoFileVM(id, root: path, name: name)
    }
    
    var body: some View {
        VStack {
            if let url = vm.localVideoURL {
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
            await vm.fetchVideoURL(name, root: path)
        }
#if os(tvOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFButton("arrow.left") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "")
                }
            }
        }
#endif
        
#if os(iOS)
        .toolbarTitleMenu {
            if vm.isSensitive {
                Button(action: unhide) {
                    Image(systemName: "eye.slash")
                }
            }
            
            Section {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    Task {
                        await fileVM.deleteFile(name, at: path) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .toolbar {
            if let url = vm.localVideoURL {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url)
                        .transition(.identity)
                }
            }
        }
#endif
    }
    
    private func unhide() {
        withAnimation {
            vm.isSensitive = false
        }
    }
}

#Preview {
    NavigationStack {
        VideoFile("id", name: "Preview", at: "")
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
