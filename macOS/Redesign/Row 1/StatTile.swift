import SwiftUI

struct StatTile: View {
    private let title: LocalizedStringKey
    private let value: String
    private let icon: String
    
    init(_ title: LocalizedStringKey, value: CustomStringConvertible, icon: String) {
        self.title = title
        self.value = value.description
        self.icon = icon
    }
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Full layout
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .fontSize(32)
                    .frame(45)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .subheadline()
                        .secondary()
                        .lineLimit(1)
                    
                    Text(value)
                        .title2(.semibold)
                }
                
                Spacer()
            }
            .frame(minWidth: 100)
            
            // Compact layout
            Image(systemName: icon)
                .fontSize(32)
                .frame(45)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.05))
        }
    }
}
