import ScrechKit
import PteroNet
import SensitiveContentAnalysis

final class SensitivityAnalyzer {
    private let analyzer = SCSensitivityAnalyzer()
    
    // Check if a URL can be converted to an image and then perform a sensitivity check
    func processImageFromURL(fileURL: URL, completion: @escaping (Bool) -> Void) {
        // file URL -> image
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            print("Failed to create an image from the file URL")
            completion(false) // Not an image
            return
        }
        
        print("Successfully created an image from the file URL")
        
        performSensitivityCheck(image, completion: completion)
    }
    
    private func performSensitivityCheck(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let cgImage = image.cgImage else {
            print("The UIImage does not have a CGImage representation")
            completion(false) // Lack of CGImage
            return
        }
        
        let policy = analyzer.analysisPolicy
        
        // Analysis is disabled
        if policy == .disabled {
            print("Analysis is disabled")
            completion(false)
            return
        }
        
        analyzer.analyzeImage(cgImage) { analysis, error in
            if let error {
                print(error.localizedDescription)
                completion(false) // Analysis error
                
            } else if let analysis, analysis.isSensitive {
                print("Sensitivity analysis result: Image is sensitive")
                completion(true) // Image is sensitive
                
            } else {
                print("No analysis results or analysis was not performed")
                completion(false) // Assume not sensitive
            }
        }
    }
}

struct QuickLookFile: View {
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
    }
    
    @State private var fileURL: URL? = nil
    @State private var isBlured = false
    
    var body: some View {
        VStack {
            if let fileURL {
                QuickLookView(fileURL)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: fileURL)
        .blur(radius: isBlured ? 10 : 0)
        .navigationTitle(name)
        .ignoresSafeArea(edges: .bottom)
        .task {
            downloadFile(name, path: path)
        }
        .toolbar {
            Button {
                withAnimation {
                    isBlured.toggle()
                }
            } label: {
                Image(systemName: isBlured ? "eye.slash" : "eye")
            }
        }
    }
    
    private func loadAndCheckImage() {
        let processor = SensitivityAnalyzer()
        
        if let fileURL {
            processor.processImageFromURL(fileURL: fileURL) { blur in
                isBlured = blur
            }
        }
    }
    
    private func downloadFile(_ file: String, path: String) {
        fileDownloadAPI(id, path: file + path) { result in
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
                        fileURL = destinationURL
                        loadAndCheckImage()
                    }
                } catch {
                    print("Error during file copy: \(error.localizedDescription)")
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
            }
        }
        .resume()
    }
}
