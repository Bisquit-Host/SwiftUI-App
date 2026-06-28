import SwiftUI

struct VDSReinstallOSVersionButton: View {
    private let item: CloudServiceOSItem
    private let isSelected: Bool
    private let action: () -> Void
    
    init(item: CloudServiceOSItem, isSelected: Bool, action: @escaping () -> Void) {
        self.item = item
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if isSelected {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }
    
    private var title: String {
        item.version ?? String(localized: "Unknown")
    }
}
