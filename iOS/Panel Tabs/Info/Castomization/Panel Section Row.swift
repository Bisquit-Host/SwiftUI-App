import SwiftUI

struct PanelSectionRow: View {
    var item: PanelSection
    var toggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .onTapGesture {
                        toggle()
                    }
                
                Text(item.name)
            }
            .title3(.semibold)
            
            if item.name == "Location" {
                HStack {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .onTapGesture {
                            toggle()
                        }
                    
                    Text("Show Ping")
                }
                .fontSize(14)
                .secondary()
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
    }
}

#Preview {
    PanelSectionList()
        .darkSchemePreferred()
}
