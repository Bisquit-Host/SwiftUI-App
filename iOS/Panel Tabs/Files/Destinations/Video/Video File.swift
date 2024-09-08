import ScrechKit
import AVKit
import PteroNet

struct VideoFile: View {
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
    }
    
    @State private var isSensitive = false
    @State private var localVideoUrl: URL?
    
    var body: some View {
        VStack {
            if let localVideoUrl {
#if os(watchOS)
                WatchVideoPlayer(localVideoUrl)
#else
                VideoPlayerView(localVideoUrl)
                    .blur(radius: isSensitive ? 10 : 0)
#endif
            }
        }
        .navigationTitle(name)
        .task {
            fetchVideoUrl(name, root: root)
        }
        .toolbar {
            if isSensitive {
                Button {
                    withAnimation {
                        isSensitive = false
                    }
                } label: {
                    Image(systemName: "eye.slash")
                }
            }
        }
    }
    
    private func fetchVideoUrl(_ name: String, root: String) {
        fileDownloadAPI(id, path: root + "/\(name)") { result in
            switch result {
            case .success(let model):
                guard let model = model?.attributes else {
                    return
                }
                
                saveVideo(model.url)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func saveVideo(_ urlString: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = fm.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            let fm = FileManager.default
            
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if fm.fileExists(atPath: fileURL.path) {
                    try fm.removeItem(at: fileURL)
                }
                
                try fm.moveItem(at: location, to: fileURL)
                
                main {
#if !os(watchOS) && !os(tvOS)
                    let processor = SensitivityAnalyzer()
                    
                    Task {
                        await processor.checkVideo(fileURL) { blur in
                            isSensitive = blur
                            self.localVideoUrl = fileURL
                        }
                    }
#else
                    self.localVideoUrl = fileURL
#endif
                }
            } catch {
                print("Error during file move: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}

#Preview {
    VideoFile("id", root: "", name: "Preview")
}
