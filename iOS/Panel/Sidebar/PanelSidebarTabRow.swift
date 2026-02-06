import SwiftUI

struct PanelSidebarTabRow: View {
    let tab: Tabs
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.rawValue)
                    .font(.headline)
                    .frame(width: 24)
                
                Text(tab.title)
                    .font(.body.weight(.semibold))
                
                Spacer(minLength: 0)
            }
            .foregroundStyle(.foreground)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(isSelected ? .gray.opacity(0.2) : .clear, in: .rect(cornerRadius: 12))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PanelSidebarTabRow(tab: .files, isSelected: true) {
    }
    .padding()
}
