import SwiftUI

struct UpgradeEmptyStateView: View {
    let message: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.up.right.circle")
                .secondary()
            
            Text(message)
                .footnote()
                .secondary()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
    }
}
