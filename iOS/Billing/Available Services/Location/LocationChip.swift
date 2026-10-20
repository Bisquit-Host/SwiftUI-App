import SwiftUI

struct LocationChip: View {
    private let location: HostingLocation
    private let isSelected: Bool
    private let action: () -> Void

    private var isSoldOut: Bool {
        location.inStock == false
    }

    init(_ location: HostingLocation, isSelected: Bool, action: @escaping () -> Void) {
        self.location = location
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                LocationChipIcon(location.flagUrl)
                    .saturation(isSoldOut ? 0 : 1)
                    .opacity(isSoldOut ? 0.6 : 1)

                VStack(alignment: .leading, spacing: 0) {
                    Text(location.name)
                        .footnote()
                        .foregroundStyle(isSelected ? .primary : .secondary)

                    if isSoldOut {
                        Text("Sold out")
                            .caption2()
                            .foregroundStyle(.tertiary)
                    }
                }
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
