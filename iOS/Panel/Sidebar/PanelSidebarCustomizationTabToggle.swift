import ScrechKit

struct PanelSidebarCustomizationTabToggle: View {
    @Environment(PanelSidebarCustomizationVM.self) private var vm
    
    let tab: Tabs
    
    var body: some View {
        Button {
            vm.toggleTabVisibility(tab)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: tab.rawValue)
                    .headline()
                    .frame(width: 20)
                
                Text(tab.title)
                
                Spacer()
                
                if vm.isTabVisible(tab) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .secondary()
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
    }
}

#Preview {
    List {
        PanelSidebarCustomizationTabToggle(tab: .info)
            .environment(PanelSidebarCustomizationVM())
    }
    .darkSchemePreferred()
}
