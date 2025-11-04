import SwiftUI

struct PanelViewTabView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(PanelVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        TabView(selection: $store.lastTabPanel) {
            if let server = vm.server {
                Tab("Info", systemImage: "info.circle", value: .info) {
                    InfoTab(server)
                        .sheet($vm.sheetSettings) {
                            ServerSettingsParent(server)
                        }
                }
                
                Tab("Console", systemImage: "terminal", value: .console) {
                    ConsoleTab(server.id)
                }
                
                Tab("Files", systemImage: "folder", value: .files) {
                    FileTab(server.id)
                }
                
                Tab("Data", systemImage: "externaldrive.badge.icloud", value: .backup) {
                    DataTab(server)
                }
                
                Tab("Startup", systemImage: "play.circle", value: .startup) {
                    StartupView(server)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    PanelViewTabView()
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
