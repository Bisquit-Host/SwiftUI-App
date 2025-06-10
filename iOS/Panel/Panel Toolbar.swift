import SwiftUI

struct PanelToolbarModifier: ViewModifier {
    @Environment(PanelVM.self) private var vm
    @Environment(ConsoleVM.self) private var consoleVM
    
    @EnvironmentObject private var fileVM: FileTabVM
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup {
                    if store.lastTabPanel == .console {
                        Button {
                            withAnimation {
                                vm.enableConsoleSearch.toggle()
                            }
                            
                            if vm.enableConsoleSearch {
                                vm.searchRule = consoleVM.command
                            }
                        } label: {
                            let icon = vm.enableConsoleSearch ? "magnifyingglass.circle.fill" : "magnifyingglass"
                            
                            Image(systemName: icon)
                        }
                        
                        Button {
                            consoleVM.inspectorPresented = true
                        } label: {
                            Image(systemName: "bold.italic.underline")
                        }
                    }
                    
                    if store.lastTabPanel == .info {
                        PowerSwitchToolbar()
                        
                        if let server = vm.server {
#if canImport(ActivityKit)
                            InfoTabLA(server)
#endif
                        }
                    }
                    
                    if store.lastTabPanel == .files {
                        if #available(iOS 18.1, *) {
                            ImagePlaygroundButton(fileVM.path)
                        }
                        
                        Button {
                            vm.alertNewFolder = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }
                
                ToolbarSpacer()
                
                ToolbarItem {
                    Button {
                        withAnimation(.easeOut) {
                            vm.sheetSettings = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .offset(x: 4)
                    }
                    .keyboardShortcut("S")
                }
            }
    }
}

extension View {
    func panelToolbar() -> some View {
        self
            .modifier(PanelToolbarModifier())
    }
}
