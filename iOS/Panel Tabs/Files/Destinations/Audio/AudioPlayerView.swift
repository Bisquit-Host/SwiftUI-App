import ScrechKit
import AudioVisualizer

struct AudioPlayerView: View {
    @State private var vm: AudioPlayerVM
    @EnvironmentObject private var fileVm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.path = path
        self.name = name
        vm = AudioPlayerVM(id)
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
            await vm.downloadFile(name, at: path)
        }
        .toolbar {
#if os(tvOS)
            ToolbarItem(placement: .topBarLeading) {
                SFButton("arrow.left") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
#else
            Menu {
                if let url = vm.audioUrl {
                    ShareLink(item: url)
                        .transition(.identity)
                } else {
                    ShareLink(item: name)
                        .disabled(vm.audioUrl == nil)
                }
                
                Section {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        Task {
                            await fileVm.deleteFile(name, at: path) {
                                dismiss()
                            }
                        }
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
    AudioPlayerView("", name: "Preview", at: "")
        .environmentObject(FileTabVM(""))
}
