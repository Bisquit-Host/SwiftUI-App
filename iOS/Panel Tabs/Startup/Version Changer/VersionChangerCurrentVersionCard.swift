import SwiftUI

struct VersionChangerCurrentVersionCard: View {
    private let title: String
    private let subtitle: String
    private let iconURL: URL?
    private let trailingSymbol: String?
    private let trailingTint: Color
    
    init(
        _ title: String,
        subtitle: String,
        iconURL: URL?,
        trailingSymbol: String? = nil,
        trailingTint: Color = .secondary
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconURL = iconURL
        self.trailingSymbol = trailingSymbol
        self.trailingTint = trailingTint
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VersionChangerTypeLogo(url: iconURL)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .subheadline(.semibold)
                
                Text(subtitle)
                    .secondary()
                    .footnote()
                    .numericTransition()
                    .lineLimit(2)
            }
            
            Spacer()
            
            if let trailingSymbol {
                Image(systemName: trailingSymbol)
                    .foregroundStyle(trailingTint)
                    .footnote()
            }
        }
    }
}

#Preview {
    VersionChangerCurrentVersionCard(
        "Version",
        subtitle: "1.21.1",
        iconURL: URL(string: "https://example.com/icon.png")
    )
    .padding()
    .darkSchemePreferred()
}
