import SwiftUI

struct SupportMediaViewer: View {
    let mediaPath: String
    let accessToken: String
    var onClose: () -> Void
    
    @State private var image: Image?
    @State private var isLoading = true
    @State private var errorText: String?
    
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
                
            } else if let errorText {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .largeTitle()
                        .foregroundStyle(.yellow)
                    
                    Text(errorText)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            
            VStack {
                HStack {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .title()
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(10)
                    }
                    
                    Spacer()
                    
                    Text(mediaPath)
                        .caption()
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Spacer()
            }
        }
        .task {
            await loadMedia()
        }
    }
    
    private func loadMedia() async {
        guard let url = buildURL(from: mediaPath) else {
            await MainActor.run { errorText = "Invalid media URL"; isLoading = false }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                let detail = String(data: data, encoding: .utf8) ?? ""
                
                await MainActor.run {
                    errorText = "Failed to load media (\(http.statusCode)) \(detail)"
                    isLoading = false
                }
                
                return
            }
            
            if let uiImage = UIImage(data: data) {
                let swiftUIImage = Image(uiImage: uiImage)
                
                await MainActor.run {
                    self.image = swiftUIImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    errorText = "Unsupported media"
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorText = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func buildURL(from path: String) -> URL? {
        if let url = URL(string: path), url.scheme != nil {
            return url
        }
        
        let cleaned = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // API expects /media/tickets/{filename}
        let filename = URL(fileURLWithPath: cleaned).lastPathComponent
        
        if cleaned.hasPrefix("media/tickets/") || cleaned.hasPrefix("/media/tickets/") {
            return URL(string: "\(baseURL)/media/tickets/\(filename)")
        } else {
            return URL(string: "\(baseURL)/media/tickets/\(filename)")
        }
    }
}

#Preview {
    SupportMediaViewer(mediaPath: "media/example.png", accessToken: "", onClose: {})
        .darkSchemePreferred()
}
