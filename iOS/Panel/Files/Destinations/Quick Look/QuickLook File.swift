import ScrechKit
import PteroNet

struct QuickLookFile: View {
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
    }
    
    @State private var fileURL: URL? = nil
    
    var body: some View {
        VStack {
            if let fileURL {
                QuickLookView(fileURL)
            }
        }
        .navigationTitle(name)
        .ignoresSafeArea(edges: .bottom)
        .task {
            downloadFile(name, path: path)
        }
    }
    
    func downloadFile(_ file: String, path: String) {
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
    
    func downloadVideo(_ urlString: String, name: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let destinationURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            if let location, error == nil {
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    try FileManager.default.copyItem(at: location, to: destinationURL)
                    
                    main {
                        self.fileURL = destinationURL
                    }
                } catch {
                    print("Error during file copy: \(error.localizedDescription)")
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
            }
        }.resume()
    }
}
