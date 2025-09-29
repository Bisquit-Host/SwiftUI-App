import ScrechKit

struct PanelToolbarModifier: ViewModifier {
    @Environment(PanelVM.self) private var vm
    @Environment(ConsoleVM.self) private var consoleVM
    
    @EnvironmentObject private var fileVM: FileTabVM
    @EnvironmentObject private var store: ValueStore
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup {
                    // Console
                    if store.lastTabPanel == .console {
                        SFButton("bold.italic.underline") {
                            consoleVM.inspectorPresented = true
                        }
                    }
                    
                    // Info
                    if store.lastTabPanel == .info {
                        PowerSwitchToolbar()
                        
                        if let server = vm.server {
#if canImport(ActivityKit)
                            InfoTabLiveActivity(server)
#endif
                        }
                    }
                    
                    // Files
                    if store.lastTabPanel == .files {
                        ImagePlaygroundButton(fileVM.path)
                        
                        SFButton("folder.badge.plus") {
                            vm.alertNewFolder = true
                        }
                        
                        UploadMenu("")
                    }
                }
                
                ToolbarSpacer()
                
                ToolbarItem {
                    SFButton("ellipsis") {
                        vm.sheetSettings = true
                    }
                    .keyboardShortcut("S")
                }
            }
    }
}

extension View {
    func panelToolbar() -> some View {
        self.modifier(PanelToolbarModifier())
    }
}
