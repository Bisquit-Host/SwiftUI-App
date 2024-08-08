import ScrechKit
import PteroNet

struct QuickLookFile: View {
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Binding var link: FileLink?
    
    init(_ link: Binding<FileLink?>) {
        _link = link
    }
    
    @State private var fileURL: URL? = nil
    
    private var id: String {
        link?.id ?? ""
    }
    
    private var name: String {
        link?.name ?? ""
    }
    
    private var root: String {
        link?.root ?? ""
    }
    
    var body: some View {
        VStack {
            if let fileURL {
                QuickLookView(fileURL)
                    .transition(.opacity)
                    .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle(name)
        .animation(.default, value: fileURL)
        .navigationTitle(name)
        .ignoresSafeArea(edges: .bottom)
        .task {
            downloadFile(name, root: root)
        }
        .toolbar {
            if let fileURL {
                ShareLink(item: fileURL)
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
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: location, to: destinationURL)
                
                main {
                    fileURL = destinationURL
                    
                    //                    Task {
                    //                        await loadAndCheckImage()
                    //                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}
