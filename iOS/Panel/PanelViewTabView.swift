import ScrechKit

struct PanelViewTabView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(PanelVM.self) private var vm
    @Environment(ConsoleVM.self) private var consoleVM
    @EnvironmentObject private var fileVM: FileTabVM
    
    var body: some View {
        if let server = vm.server {
            switch store.lastTabPanel {
            case .info:
                InfoTab(server)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            PowerSwitchToolbar()
                            
#if canImport(ActivityKit)
                            InfoTabLiveActivity(server)
#endif
                            PanelSettingsToolbarButton()
                        }
                    }
                
            case .console:
                ConsoleTab(server.id)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            SFButton("bold.italic.underline") {
                                consoleVM.inspectorPresented = true
                            }
                            
                            PanelSettingsToolbarButton()
                        }
                    }
                
            case .files:
                FileTab(server.id)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            ImagePlaygroundButton(fileVM.path)
                            
                            SFButton("folder.badge.plus") {
                                vm.alertNewFolder = true
                            }
                            
                            UploadMenu("")
                            PanelSettingsToolbarButton()
                        }
                    }
                
            case .backup:
                DataTab(server)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            PanelSettingsToolbarButton()
                        }
                    }
                
            case .startup:
                StartupView(server)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            PanelSettingsToolbarButton()
                        }
                    }
                
            case .subdomain:
                InfoTabSubdomains(server)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            PanelSettingsToolbarButton()
                        }
                    }
            }
        } else {
            ContentUnavailableView("Loading server", systemImage: "server.rack")
        }
    }
}

#Preview {
    PanelViewTabView()
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(FileTabVM(""))
        .environmentObject(ValueStore())
}
