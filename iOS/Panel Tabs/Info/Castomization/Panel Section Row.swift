import SwiftUI

struct PanelSectionRow: View {
    private var item: PanelSection
    private var toggle: () -> Void
    
    init(_ item: PanelSection, toggle: @escaping () -> Void) {
        self.item = item
        self.toggle = toggle
    }
    
    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .onTapGesture {
                    toggle()
                }
            
            Text(item.loc)
        }
        .title3(.semibold)
    }
}

#Preview {
    PanelSectionList()
        .darkSchemePreferred()
}
