import SwiftUI

struct UpgradeSpecChip: View {
    let spec: (icon: String, text: String)
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: spec.icon)
                .footnote()
                .secondary()
            
            Text(spec.text)
                .footnote()
                .monospacedDigit()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(isSelected ? Color.accentColor.opacity(0.12) : .primary.opacity(0.04), in: .capsule)
        .overlay {
            Capsule()
                .stroke(isSelected ? Color.accentColor.opacity(0.35) : .primary.opacity(0.1), lineWidth: 1)
        }
    }
}
