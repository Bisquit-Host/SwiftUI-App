import ScrechKit
import PteroNet

struct QuickLookFile: View {
    private let id, path, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.path = root
        self.name = name
    }
    
    @State private var fileURL: URL? = nil
    @State private var isSensitive = false
    
    var body: some View {
        VStack {
            if let fileURL {
                QuickLookView(fileURL)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: fileURL)
        .blur(radius: isSensitive ? 10 : 0)
        .navigationTitle(name)
        .ignoresSafeArea(edges: .bottom)
        .task {
            downloadFile(name, root: path)
        }
        .toolbar {
            if let fileURL {
                ShareLink(item: fileURL)
            }
            
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
    
    private func loadAndCheckImage() {
        let processor = SensitivityAnalyzer()
        
        guard let fileURL else {
            return
        }
        
        Task {
            await processor.checkImage(fileURL) { blur in
                isSensitive = blur
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
                    fileURL = destinationURL
                    
                    Task {
                        loadAndCheckImage()
                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}
