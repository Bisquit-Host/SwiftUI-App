import ScrechKit

struct PanelSettingsToolbarButton: View {
    @Environment(PanelVM.self) private var vm
    
    var body: some View {
        SFButton("ellipsis") {
            vm.sheetSettings = true
        }
        .keyboardShortcut("S")
    }
}

#Preview {
    PanelSettingsToolbarButton()
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
