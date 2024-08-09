import ScrechKit
import PteroNet
import ZIPFoundation

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
    
    private var mimeType: String {
        link?.mimeType ?? ""
    }
    
    @State private var extractedFileNames: [String] = []
    
    var body: some View {
        VStack {
            if let fileURL {
                QuickLookView(fileURL)
                    .transition(.opacity)
                    .padding()
                
                if mimeType.contains("zip") {
                    if extractedFileNames.isEmpty {
                        Button("Extract files") {
                            extractFiles(fileURL)
                        }
                        .padding(.bottom)
                    } else {
                        List(extractedFileNames, id: \.self) { url in
                            VStack {
                                NavigationLink  {
                                    QuickLookView(URL(string: url)!)
                                } label: {
                                    Text(url)
                                }
                                
                                if let files = FileManager.default.contents(atPath: url) {
                                    Text("\(files.count)")
                                } else {
                                    Text("Fileded")
                                }
                            }
                        }
                    }
                }
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
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
    
    //    private func extractFiles(_ zipFileURL: URL) {
    //        var tempDir = FileManager.default.temporaryDirectory
    //        tempDir.appendPathComponent("extracted_files")
    //
    //        // Create directory
    //        if !FileManager.default.fileExists(atPath: tempDir.path) {
    //            do {
    //                try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
    //            } catch {
    //                print("Failed to create directory: \(error.localizedDescription)")
    //                return
    //            }
    //        }
    //
    //        // Unzip
    //        do {
    //            try FileManager.default.unzipItem(at: zipFileURL, to: tempDir)
    //
    //            extractedFileUrls = try FileManager.default.contentsOfDirectory(atPath: tempDir.path)
    //
    //            for url in extractedFileUrls {
    //                let size = FileManager.default.contents(atPath: url)?.count
    //                print("size: \(String(describing: size))")
    //            }
    //            print("Unzipped successfully to \(tempDir)")
    //        } catch {
    //            print("Failed to unzip: \(error.localizedDescription)")
    //        }
    //    }
    private func extractFiles(_ destinationURL: URL) {
        // The path to the archive file (e.g., "archive.zip")
        let archiveURL = URL(fileURLWithPath: destinationURL.path)
        
        // Ensure the destination URL is pointing to the correct directory
        var tempDirectoryURL = FileManager.default.temporaryDirectory
        tempDirectoryURL.appendPathComponent("extracted_files")
        
        do {
            // Create the extracted_files directory if it doesn't exist
            if !FileManager.default.fileExists(atPath: tempDirectoryURL.path) {
                try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
            return
        }
        
        // Open the archive
        guard let archive = try? Archive(url: archiveURL, accessMode: .read, pathEncoding: .utf8) else {
            print("Failed to open archive")
            return
        }
        
        // Extract all files from the archive
        for entry in archive {
            do {
                let destURL = tempDirectoryURL.appendingPathComponent(entry.path)
                
                // Ensure that the directory structure is created
                let destDirectory = destURL.deletingLastPathComponent()
                
                if !FileManager.default.fileExists(atPath: destDirectory.path) {
                    try FileManager.default.createDirectory(at: destDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                
                // If the file already exists, remove it
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                
                var size = 0
                // Extract the entry to the destination URL
                _ = try archive.extract(entry, bufferSize: 1024 * 1024) { data in
                    size += data.count
                }
                
                print(formatBytes(size, countStyle: .memory))
                //                _ = try archive.extract(entry, to: destURL, progress: <#T##Progress?#>)
                
                extractedFileNames.append(destURL.path)
                
                print("Extracted file: \(entry.path)")
                print("Extracted file: \(destURL)")
            } catch {
                print("Extracting entry from archive failed with error: \(error)\n")
            }
        }
        //
        //        //                    if let url = Archieving().decompress(destinationURL.path) {
        //        //                        if let files = FileManager.default.contents(atPath: url.path) {
        //        //                            print(files.count)
        //        //                        } else {
        //        //                            print("Fileded")
        //        //                        }
        //        //                    } else {
        //        //                        print("Ded")
        //        //                    }
        //        //
        //        //                    print("22222")
        //        //
        //        //                    if let data = FileManager.default.contents(atPath: location.path) {
        //        //                        do {
        //        //                            let decompressedData = try (data as NSData).decompressed(using: .lzma)
        //        //
        //        //                            // Assuming the decompressed data is an archive (e.g., a tar or zip file)
        //        //                            let tempDirectory = FileManager.default.temporaryDirectory
        //        //                            let tempFileURL = tempDirectory.appendingPathComponent("tempArchive")
        //        //
        //        //                            // Write the decompressed data to a temporary file
        //        //                            try decompressedData.write(to: tempFileURL)
        //        //
        //        //                            // Extract the files from the archive (if applicable)
        //        //                            let fileManager = FileManager.default
        //        //                            let extractedFiles = try fileManager.contentsOfDirectory(at: tempDirectory.appending(path: "tempArchive"), includingPropertiesForKeys: nil, options: [])
        //        //
        //        //                            print("Extracted files: \(extractedFiles.count)")
        //        //
        //        //                            // Print the names of the decompressed files
        //        //                            for file in extractedFiles {
        //        //                                print("Decompressed file: \(file.lastPathComponent)")
        //        //                            }
        //        //                        } catch {
        //        //                            print("Dempression failed: \(error.localizedDescription)")
        //        //                        }
        //        //                    } else {
        //        //                        print("Failed to read data at path: \(location.path)")
        //        //                    }
        //        //
        //
        //        //                    Task {
        //        //                        await loadAndCheckImage()
        //        //                    }
        //
    }
}
