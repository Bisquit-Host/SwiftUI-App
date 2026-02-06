import ScrechKit

struct PanelViewTabView: View {
    @Environment(PanelVM.self) private var vm
    @Environment(ConsoleVM.self) private var consoleVM
    @EnvironmentObject private var fileVM: FileTabVM
    
    let selectedTab: Tabs
    
    var body: some View {
        if let server = vm.server {
            switch selectedTab {
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
    PanelViewTabView(selectedTab: .info)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(FileTabVM(""))
        .environmentObject(ValueStore())
}
