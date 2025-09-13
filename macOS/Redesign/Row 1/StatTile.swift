import SwiftUI

struct StatTile: View {
    private let title: LocalizedStringKey
    private let value: Int
    private let icon: String
    
    init(_ title: LocalizedStringKey, value: Int, icon: String) {
        self.title = title
        self.value = value
        self.icon = icon
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .fontSize(32)
                    .frame(45)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .subheadline()
                        .secondary()
                    
                    Text(value)
                        .title2(.semibold)
                }
                
                Spacer()
            }
            .padding(16)
            .background(.thinMaterial, in: .rect(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.05))
            }
        }
        .buttonStyle(.plain)
    }
}
