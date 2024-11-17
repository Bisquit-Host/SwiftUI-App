import ScrechKit
import PteroNet
import QuickLooking

struct QuickLookFile: View {
    
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
    }
    
    @State private var fileURL: URL? = nil
    @State private var isSensitive = false
    @State private var showImagePlayground = false
    
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
            downloadFile(name, root: root)
        }
        .toolbar {
            if let fileURL {
                if #available(iOS 18.1, *) {
                    @Environment(\.supportsImagePlayground) var supportsImagePlayground
                    
                    Button {
                        showImagePlayground = true
                    } label: {
                        Image(.appleIntelligence)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .opacity(supportsImagePlayground ? 1 : 0.3)
                    }
                    .disabled(!supportsImagePlayground)
                    .sheet($showImagePlayground) {
                        NavigationView {
                            ImagePlayground(fileURL, root: root)
                        }
                    }
                }
                
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
                    fileURL = destinationURL
                    
                    Task {
                        await loadAndCheckImage()
                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}
