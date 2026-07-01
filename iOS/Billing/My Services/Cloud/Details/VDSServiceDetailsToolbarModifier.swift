import ScrechKit

struct VDSServiceDetailsToolbarModifier: ViewModifier {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    @Binding var selectedTab: Int
    @Binding var pendingName: String
    @Binding var alertRename: Bool
    @Binding var alertChangePassword: Bool
    @Binding var sheetReinstallOS: Bool
    @Binding var sheetSSHCredentials: Bool
    @Binding var sheetSSHLogs: Bool
    let serviceId: Int
    
    func body(content: Content) -> some View {
        content.toolbar {
            if selectedTab == 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Start", systemImage: "play") {
                            Task {
                                await vm.power("start", serviceId: serviceId)
                            }
                        }
                        
                        Button("Stop", systemImage: "stop") {
                            Task {
                                await vm.power("stop", serviceId: serviceId)
                            }
                        }
                        
                        Button("Restart", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                            Task {
                                await vm.power("restart", serviceId: serviceId)
                            }
                        }
                    } label: {
                        Image(systemName: "power")
                            .foregroundStyle(vm.service?.state.color ?? .gray)
                    }
                }
#if !os(visionOS)
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
#endif
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Rename", systemImage: "pencil") {
                            pendingName = vm.service?.name ?? ""
                            alertRename = true
                        }
                        
                        Divider()
                        
                        if let password = vm.service?.password {
                            Button("Copy password", systemImage: "document.on.document") {
                                Pasteboard.copy(password)
                                SystemAlert.copied()
                            }
                        }
                        
                        Button("Change password", systemImage: "lock") {
                            alertChangePassword = true
                        }
                        
                        Button("Reinstall OS", systemImage: "arrow.triangle.2.circlepath") {
                            sheetReinstallOS = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            } else if selectedTab == 3 {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Change credentials", systemImage: "key") {
                            sheetSSHCredentials = true
                        }
                        
                        Button("Logs", systemImage: "list.bullet.rectangle") {
                            sheetSSHLogs = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}
