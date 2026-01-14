import ScrechKit

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var selectedTab = 0
    @State private var pendingName = ""
    @State private var newPassword = ""
    @State private var alertRename = false
    @State private var alertChangePassword = false
    
    // SSH
    @State private var sheetSSHCredentials = false
    @State private var sheetSSHLogs = false
    @State private var host = ""
    @State private var port = "22"
    @State private var username = "root"
    @State private var password = ""
    @State private var logs: [String] = []
    
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
                VDSServiceDetails(serviceId)
            }
            
            Tab("Protection", systemImage: "shield.lefthalf.filled", value: 1) {
                VDSProtection(serviceId)
            }
            
            Tab("History", systemImage: "clock", value: 2) {
                VDSServiceHistoryTab(serviceId)
            }
#if canImport(SwiftTerm) && canImport(NIOSSH)
            Tab("SSH", systemImage: "terminal", value: 3) {
                VDSSSHTab(host: $host, port: $port, username: $username, password: $password, logs: $logs)
            }
#endif
        }
        .navigationTitle(title ?? "\(vm.service?.name ?? "")")
#if !os(visionOS)
        .navigationSubtitle(subtitle)
#endif
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .modifier(VDSServiceDetailsToolbarModifier(
            selectedTab: $selectedTab,
            pendingName: $pendingName,
            alertRename: $alertRename,
            alertChangePassword: $alertChangePassword,
            sheetSSHCredentials: $sheetSSHCredentials,
            sheetSSHLogs: $sheetSSHLogs,
            serviceId: serviceId
        ))
        .environment(vm)
#if !os(visionOS)
        .sheet($sheetSSHCredentials) {
            NavigationStack {
                VDSSheetSSHCredentials(host: $host, port: $port, username: $username, password: $password)
            }
        }
        .sheet($sheetSSHLogs) {
            NavigationStack {
                VDSSheetSSHLogs($logs)
            }
        }
#endif
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
            
            Button("Save", role: .confirm, action: changePassword)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func changePassword() {
        Task {
            await vm.changePassword(newPassword, for: serviceId)
            newPassword = ""
        }
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetailsTabView(1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
