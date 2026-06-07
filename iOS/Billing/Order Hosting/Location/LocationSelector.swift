import SwiftUI

struct LocationSelector: View {
    private let locations: [HostingLocation]
    private let selectedLocationId: Int?
    private let onSelect: (Int?) -> Void
    
    init(_ locations: [HostingLocation], selectedLocationId: Int?, onSelect: @escaping (Int?) -> Void) {
        self.locations = locations
        self.selectedLocationId = selectedLocationId
        self.onSelect = onSelect
    }
    
    var body: some View {
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
}
