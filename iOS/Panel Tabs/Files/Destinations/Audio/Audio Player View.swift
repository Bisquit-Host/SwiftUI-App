import ScrechKit
import AudioVisualizer

struct AudioPlayerView: View {
    @State private var vm: AudioPlayerVM
    @EnvironmentObject private var fileVm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = AudioPlayerVM(id)
    }
    
    var body: some View {
        VStack {
            if let url = vm.audioUrl {
                AudioVisualizerView(url, fileName: name, image: Image(.artwork))
            } else {
                ProgressView()
            }
        }
        .ignoresSafeArea()
        .task {
            vm.downloadFile(name, at: path)
        }
        .toolbar {
#warning("Doesn't work on tvOS")
            Menu {
#if !os(tvOS)
                if let url = vm.audioUrl {
                    ShareLink(item: url)
                        .transition(.identity)
                } else {
                    ShareLink(item: name)
                        .disabled(vm.audioUrl == nil)
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
        }
    }
}

#Preview {
    AudioPlayerView("", path: "", name: "Preview")
        .environmentObject(FileTabVM(""))
}
