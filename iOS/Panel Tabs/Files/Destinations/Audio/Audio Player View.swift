import ScrechKit
import PteroNet
import AudioVisualizer

struct AudioPlayerView: View {
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
    }
    
    @State private var audioUrl: URL?
    
    var body: some View {
        VStack {
            if let audioUrl {
                AudioVisualizerView(audioUrl, fileName: name, image: Image(.artwork))
            } else {
                ProgressView()
            }
        }
        .ignoresSafeArea()
        .task {
            downloadFile(name, root: root)
        }
        .toolbar {
            if let audioUrl {
                ShareLink(item: audioUrl)
                    .transition(.identity)
            } else {
                ShareLink(item: name)
                    .disabled(audioUrl == nil)
            }
        }
    }
    
    private func downloadFile(_ file: String, root: String) {
        fileDownloadAPI(id, path: root + "/\(file)") { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes.url {
                    downloadVideo(model, name: file)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func downloadVideo(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = fm.temporaryDirectory
        let destinationURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            let fm = FileManager.default
            
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if fm.fileExists(atPath: destinationURL.path) {
                    try fm.removeItem(at: destinationURL)
                }
                
                try fm.copyItem(at: location, to: destinationURL)
                
                main {
                    withAnimation {
                        audioUrl = destinationURL
                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}

#Preview {
    AudioPlayerView("", root: "", name: "Preview")
}
