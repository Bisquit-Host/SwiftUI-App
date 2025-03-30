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
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if store.lastTabPanel == .console {
                        Button {
                            withAnimation {
                                vm.enableConsoleSearch.toggle()
                            }
                            
                            if vm.enableConsoleSearch {
                                vm.searchRule = consoleVM.command
                            }
                        } label: {
                            Image(systemName: vm.enableConsoleSearch ? "magnifyingglass.circle.fill" : "magnifyingglass")
                                .fontSize(16)
                                .frame(width: 35, height: 35)
                                .background(.ultraThinMaterial, in: .circle)
                        }
                        .foregroundStyle(.primary)
                        
                        Button {
                            consoleVM.inspectorPresented = true
                        } label: {
                            Image(systemName: "bold.italic.underline")
                                .fontSize(10)
                                .bold()
                                .frame(width: 35, height: 35)
                                .background(.ultraThinMaterial, in: .circle)
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, -10)
                    }
                    
                    if store.lastTabPanel == .info, let server = vm.server {
#if canImport(ActivityKit)
                        InfoTabLA(server)
#endif
                    }
                    
                    if store.lastTabPanel == .files {
                        if #available(iOS 18.1, *) {
                            ImagePlaygroundButton(fileVM.path)
                        }
                        
                        Button {
                            vm.alertNewFolder = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                                .footnote(.bold)
                                .frame(width: 35, height: 35)
                                .background(.ultraThinMaterial, in: .circle)
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, -10)
                    }
                    
                    Button {
                        withAnimation(.easeOut) {
                            vm.sheetSettings = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .footnote(.bold)
                            .frame(width: 35, height: 35)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                    .foregroundStyle(.primary)
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
