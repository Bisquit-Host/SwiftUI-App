import ScrechKit

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    let serviceId: Int
    
    @State private var selectedTab = 0
    @State private var pendingName = ""
    @State private var newPassword = ""
    @State private var alertRename = false
    @State private var alertChangePassword = false
    
    private var title: LocalizedStringKey? {
        switch selectedTab {
        case 1: "Protection"
        case 2: "History"
        case 3: "SSH"
        default: nil
        }
    }
    
    private var subtitle: String {
        guard
            selectedTab == 0,
            let name = vm.service?.packageInfo.name,
            let location = vm.service?.location.name
        else {
            return ""
        }
        
        return "\(name) • \(location)"
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("General", systemImage: "gear", value: 0) {
                VDSServiceDetails(serviceId: serviceId)
            }
            
            Tab("Protection", systemImage: "shield.lefthalf.filled", value: 1) {
                VDSProtection(serviceId: serviceId)
            }
            
            Tab("History", systemImage: "clock", value: 2) {
                VDSServiceHistoryTab(serviceId: serviceId)
            }

#if canImport(SwiftTerm) && canImport(NIOSSH)
            Tab("SSH", systemImage: "terminal", value: 3) {
                VDSSSHTabView()
            }
#endif
        }
        .environment(vm)
        .navigationTitle(title ?? "\(vm.service?.name ?? "")")
        .navigationSubtitle(subtitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .alert("Rename service", isPresented: $alertRename, presenting: vm.service) { service in
            TextField("New name", text: $pendingName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Save") {
                Task {
                    await vm.rename(pendingName.isEmpty ? service.name : pendingName, serviceId: service.id)
                    pendingName = ""
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .alert("Change password", isPresented: $alertChangePassword) {
            SecureField("New password", text: $newPassword)
            
            Button("Save", role: .cancel) {
                Task {
                    await vm.changePassword(newPassword, serviceId: serviceId)
                    newPassword = ""
                }
            }
        }
        .toolbar {
            if selectedTab == 0 {
                if vm.isPerformingAction {
                    ProgressView()
                } else {
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
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetailsTabView(serviceId: 1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
