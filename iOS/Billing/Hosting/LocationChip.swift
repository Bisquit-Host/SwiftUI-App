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
                if let flag = location.flagUrl, let url = URL(string: flag) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.15)
                    }
                    .frame(width: 28, height: 18)
                    .clipShape(.rect(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.primary.opacity(0.08), lineWidth: 1)
                    }
                }
                
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
