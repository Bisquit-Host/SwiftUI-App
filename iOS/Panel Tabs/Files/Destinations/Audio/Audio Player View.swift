import ScrechKit
import AudioVisualizer

struct AudioPlayerView: View {
    @State private var vm: AudioPlayerVM
    
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
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
            vm.downloadFile(name, root: root)
        }
        .toolbar {
            if let url = vm.audioUrl {
                ShareLink(item: url)
                    .transition(.identity)
            } else {
                ShareLink(item: name)
                    .disabled(vm.audioUrl == nil)
            }
        }
    }
}

#Preview {
    AudioPlayerView("", root: "", name: "Preview")
}
