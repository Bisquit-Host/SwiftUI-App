import SwiftUI

struct ResourceGraphSectionUptime: View {
    @Environment(PanelVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        HStack {
            Text("Uptime")
                .footnote()
                .secondary()
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(Converter.millisecondsToTime(vm.uptime))
                    .caption2()
                    .secondary()
                    .monospacedDigit()
            }
        }
        .padding(10)
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

#Preview {
    ResourceGraphSectionUptime()
}
