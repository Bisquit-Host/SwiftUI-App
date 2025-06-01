import ScrechKit
import PteroNet
import QuickLooking

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
            await fetchDownloadUrl(name, at: root)
        }
        .toolbar {
            if let fileURL {
                ShareLink(item: fileURL)
            }
        }
    }
    
    private func fetchDownloadUrl(_ file: String, at root: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: root + "/" + file)
            downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = fm.temporaryDirectory
        let destinationURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location, error == nil else {
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: location, to: destinationURL)
                
                main {
                    fileURL = destinationURL
                }
            } catch {
                print("Error during file copy:", error.localizedDescription)
            }
        }
        .resume()
    }
}
