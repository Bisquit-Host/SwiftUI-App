import SwiftUI

struct LocationSelector: View {
    let locations: [HostingLocation]
    let selectedLocationId: Int?
    let onSelect: (Int?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .footnote()
                .secondary()
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(locations) { location in
                        LocationChip(location, isSelected: selectedLocationId == location.id) {
                            onSelect(location.id)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.never)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
    }
}
