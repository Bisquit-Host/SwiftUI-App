import SwiftUI
import Calagopus

struct FTBModpackModRowView: View {
    let mod: FTBModpackVersionMod
    let metadata: FTBModpackVersionModMetadata?
    let openLink: (String) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            FTBModpackModIconView(metadata?.iconURL)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(displayName)
                    .subheadline(.semibold)
                    .lineLimit(1)
                
                if let authorsText {
                    Text(authorsText)
                        .caption()
                        .secondary()
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    if mod.clientOnly {
                        Text("Client")
                            .caption2()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.thinMaterial, in: .capsule)
                    }
                    
                    if mod.serverOnly {
                        Text("Server")
                            .caption2()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.thinMaterial, in: .capsule)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .contextMenu {
            if let modPageURL {
                Section {
                    Button("Open mod page", systemImage: "safari") {
                        openLink(modPageURL)
                    }
                }
            }
            
            ForEach(linkedAuthors) { author in
                Button("Open \(author.name)", systemImage: "person") {
                    guard let profileURL = author.profileURLString else {
                        return
                    }
                    
                    openLink(profileURL)
                }
            }
        }
    }
    
    private var displayName: String {
        if let resolvedName = metadata?.displayName,
           resolvedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return resolvedName
        }
        
        return mod.fallbackDisplayName
    }
    
    private var authorsText: String? {
        guard let metadata, metadata.authors.isEmpty == false else {
            return nil
        }
        
        return metadata.authors
            .map(\.name)
            .joined(separator: ", ")
    }
    
    private var linkedAuthors: [FTBModpackAuthor] {
        guard let metadata else { return [] }
        
        return metadata.authors.filter {
            $0.profileURLString?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
    }
    
    private var modPageURL: String? {
        let metadataURL = metadata?.projectURLString?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let metadataURL, metadataURL.isEmpty == false {
            return metadataURL
        }
        
        let sourceURL = mod.sourceURLString?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let sourceURL, sourceURL.isEmpty == false {
            return sourceURL
        }
        
        return nil
    }
}
