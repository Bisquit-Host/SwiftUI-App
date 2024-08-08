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
                    
                    
                    
//                    if let url = Archieving().decompress(destinationURL.path) {
//                        if let files = FileManager.default.contents(atPath: url.path) {
//                            print(files.count)
//                        } else {
//                            print("Fileded")
//                        }
//                    } else {
//                        print("Ded")
//                    }
//                    
//                    print("22222")
//                    
//                    if let data = FileManager.default.contents(atPath: location.path) {
//                        do {
//                            let decompressedData = try (data as NSData).decompressed(using: .lzma)
//                            
//                            // Assuming the decompressed data is an archive (e.g., a tar or zip file)
//                            let tempDirectory = FileManager.default.temporaryDirectory
//                            let tempFileURL = tempDirectory.appendingPathComponent("tempArchive")
//
//                            // Write the decompressed data to a temporary file
//                            try decompressedData.write(to: tempFileURL)
//
//                            // Extract the files from the archive (if applicable)
//                            let fileManager = FileManager.default
//                            let extractedFiles = try fileManager.contentsOfDirectory(at: tempDirectory.appending(path: "tempArchive"), includingPropertiesForKeys: nil, options: [])
//
//                            print("Extracted files: \(extractedFiles.count)")
//                            
//                            // Print the names of the decompressed files
//                            for file in extractedFiles {
//                                print("Decompressed file: \(file.lastPathComponent)")
//                            }
//                        } catch {
//                            print("Dempression failed: \(error.localizedDescription)")
//                        }
//                    } else {
//                        print("Failed to read data at path: \(location.path)")
//                    }
//                    
                    
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
