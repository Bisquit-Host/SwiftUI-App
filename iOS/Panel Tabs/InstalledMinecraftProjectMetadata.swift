import SwiftUI

struct InstalledMinecraftProjectMetadata: View {
    let version: String?
    let provider: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let version {
                Text(version)
            }
            
            if let provider {
                Text(provider)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}
