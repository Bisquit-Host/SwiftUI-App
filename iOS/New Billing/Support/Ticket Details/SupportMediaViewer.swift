import SwiftUI

struct SupportMediaViewer: View {
    let mediaPath: String
    let accessToken: String
    var onClose: () -> Void
    
    @State private var image: Image?
    @State private var isLoading = true
    
    private let baseURL = "https://test-api.bisquit.host"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
            } else if isLoading {
                ProgressView()
                    .tint(.white)
            }
        }
        .navigationTitle(mediaPath)
        .toolbarTitleDisplayMode(.inline)
        .task {
            await loadMedia()
        }
        .toolbar {
            Button(role: .destructive) {
                onClose()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
    
    private func loadMedia() async {
        guard let url = buildURL(mediaPath) else {
            print("Invalid media URL")
            isLoading = false
            
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                let detail = String(data: data, encoding: .utf8) ?? ""
                
                print(http.statusCode, "Failed to load media;", detail)
                isLoading = false
                
                return
            }
            
            if let uiImage = UIImage(data: data) {
                let swiftUIImage = Image(uiImage: uiImage)
                
                image = swiftUIImage
                isLoading = false
            } else {
                print("Unsupported media")
                isLoading = false
            }
        } catch {
            print(error.localizedDescription)
            isLoading = false
        }
    }
    
    private func buildURL(_ path: String) -> URL? {
        if let url = URL(string: path), url.scheme != nil {
            return url
        }
        
        let cleaned = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let filename = URL(fileURLWithPath: cleaned).lastPathComponent
        
        if cleaned.hasPrefix("media/tickets/") || cleaned.hasPrefix("/media/tickets/") {
            return URL(string: "\(baseURL)/media/tickets/\(filename)")
        } else {
            return URL(string: "\(baseURL)/media/tickets/\(filename)")
        }
    }
}

#Preview {
    SupportMediaViewer(mediaPath: "media/example.png", accessToken: "") {}
        .darkSchemePreferred()
}
