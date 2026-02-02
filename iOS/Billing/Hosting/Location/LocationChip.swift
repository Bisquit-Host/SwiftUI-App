import SwiftUI

struct LocationChip: View {
    private let location: HostingLocation
    private let isSelected: Bool
    private let action: () -> Void
    
    init(_ location: HostingLocation, isSelected: Bool, action: @escaping () -> Void) {
        self.location = location
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                LocationChipIcon(location.flagUrl)
                
                Text(location.name)
                    .footnote()
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.systemBackground).opacity(0.6))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor.opacity(0.4) : .primary.opacity(0.05), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
