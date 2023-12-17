import ScrechKit
import AVKit
import PteroNet

struct DesVideo: View {
    private let id, path, name: String
    
    init(_ id: String,
         path: String,
         name: String
    ) {
        self.id = id
        self.path = path
        self.name = name
    }
    
    @State private var localVideoUrl: URL?
    
    var body: some View {
        VStack {
            if let localVideoUrl {
#if !os(watchOS)
                RemoteVideoPlayer(localVideoUrl)
#else
                DesWatchTvVideo(localVideoUrl)
#endif
            }
        }
        .navigationTitle(name)
        .onDisappear {
            deleteVideo()
        }
        .task {
            downloadImage(name, path: path)
        }
    }
    
    private func downloadImage(_ file: String, path: String) {
        downloadFileAPI(id, from: file + path) { result in
            switch result {
            case .success(let model):
                if let model {
                    downloadVideo(model.attributes.url, name: file)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    private func downloadVideo(_ urlString: String, name: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(name)
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            if let location, error == nil {
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                    
                    try FileManager.default.copyItem(at: location, to: fileURL)
                    
                    main {
                        self.localVideoUrl = fileURL
                    }
                } catch {
                    print("Error during file copy: \(error.localizedDescription)")
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
            }
        }
        
        downloadTask.resume()
    }
    
    private func deleteVideo() {
        guard let url = localVideoUrl else { 
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to delete video: \(error)")
        }
    }
}

#Preview {
    DesVideo("", path: "", name: "")
}
