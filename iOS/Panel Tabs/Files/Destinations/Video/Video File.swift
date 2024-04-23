import ScrechKit
import AVKit
import PteroNet

struct VideoFile: View {
    private let id, root, name: String
    
    init(_ id: String,
         root: String,
         name: String
    ) {
        self.id = id
        self.root = root
        self.name = name
    }
    
    @State private var localVideoUrl: URL?
    
    var body: some View {
        VStack {
            if let localVideoUrl {
#if os(watchOS)
                WatchVideoPlayer(localVideoUrl)
#else
                VideoPlayerView(localVideoUrl)
#endif
            }
        }
        .navigationTitle(name)
        .task {
            fetchVideoUrl(name, root: root)
        }
    }
    
    private func fetchVideoUrl(_ name: String, root: String) {
        fileDownloadAPI(id, path: root + "/\(name)") { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    saveVideo(model.url)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    private func saveVideo(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            if let location = location, error == nil {
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                    
                    try FileManager.default.moveItem(at: location, to: fileURL)
                    
                    main {
                        self.localVideoUrl = fileURL
                    }
                } catch {
                    print("Error during file move: \(error.localizedDescription)")
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
            }
        }
        .resume()
    }
}

#Preview {
    VideoFile("",
              root: "",
              name: "")
}
