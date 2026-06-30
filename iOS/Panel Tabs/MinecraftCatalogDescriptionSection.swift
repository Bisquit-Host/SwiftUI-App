import SwiftUI
import Calagopus
import Kingfisher
import OSLog
import Translation

struct MinecraftCatalogDescriptionSection: View {
    @EnvironmentObject private var store: ValueStore
    
    private let project: MinecraftCatalogProject
    
    @State private var showTranslation = false
    
    init(_ project: MinecraftCatalogProject) {
        self.project = project
    }
    
    var body: some View {
        BillingSectionCard("Description", showsBackground: false) {
            ForEach(descriptionSegments) {
                switch $0 {
                case .text(_, let value):
                    Text(value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                case .image(_, let url, let caption):
                    if let imageURL = URL(string: url) {
                        VStack(spacing: 6) {
                            KFImage(imageURL)
                                .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .scaledToFit()
                                .clipShape(.rect(cornerRadius: 12))
                                .contextMenu {
                                    Button("Save", systemImage: "square.and.arrow.down") {
                                        Task {
                                            await saveImage(from: imageURL)
                                        }
                                    }
                                    
                                    ShareLink(item: imageURL)
                                }
                            
                            if !caption.isEmpty {
                                Text(caption)
                                    .footnote()
                                    .secondary()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    } else {
                        Text(url)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        } primaryButton: {
            TranslateButton($showTranslation, text: project.description)
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        .translationPresentation(
            isPresented: $showTranslation,
            text: project.description
        )
    }
    
    private func saveImage(from url: URL) async {
        do {
            let data = try await fetchMinecraftInstallerExternalData(url: url, accept: "*/*")
            
            guard let uiImage = UIImage(data: data) else {
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        } catch {
            Logger().error("\(error)")
        }
    }
    
    private var descriptionSegments: [DescriptionSegment] {
        let pattern = #"[!:]\[([^\]]*)\]\(([^)\s]+)\)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [.text(UUID(), project.description)]
        }
        
        let description = project.description
        let range = NSRange(description.startIndex..., in: description)
        let matches = regex.matches(in: description, range: range)
        
        guard !matches.isEmpty else {
            return [.text(UUID(), description)]
        }
        
        var segments: [DescriptionSegment] = []
        var currentIndex = description.startIndex
        
        for match in matches {
            guard
                let fullRange = Range(match.range, in: description),
                let captionRange = Range(match.range(at: 1), in: description),
                let urlRange = Range(match.range(at: 2), in: description)
            else {
                continue
            }
            
            if currentIndex < fullRange.lowerBound {
                let textPart = String(description[currentIndex ..< fullRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !textPart.isEmpty {
                    segments.append(.text(UUID(), textPart))
                }
            }
            
            let caption = String(description[captionRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let imageURL = String(description[urlRange])
            segments.append(.image(UUID(), imageURL, caption))
            
            currentIndex = fullRange.upperBound
        }
        
        if currentIndex < description.endIndex {
            let textPart = String(description[currentIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !textPart.isEmpty {
                segments.append(.text(UUID(), textPart))
            }
        }
        
        return segments
    }
}

private enum DescriptionSegment: Identifiable {
    case text(UUID, String),
         image(UUID, String, String)
    
    var id: UUID {
        switch self {
        case .text(let id, _), .image(let id, _, _):
            id
        }
    }
}
