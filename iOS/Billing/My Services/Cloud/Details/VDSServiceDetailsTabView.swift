import ScrechKit

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    private let serviceID: Int
    
    init(_ serviceID: Int) {
        self.serviceID = serviceID
    }
    
    @State private var selectedTab = 0
    @State private var pendingName = ""
    @State private var newPassword = ""
    @State private var alertRename = false
    @State private var alertChangePassword = false
    @State private var sheetReinstallOS = false
    
    // SSH
    @State private var sheetSSHCredentials = false
    @State private var sheetSSHLogs = false
    @State private var sshCredentials = SSHCredentialsState()
    @State private var sshStatus = ""
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
        switch selectedTab {
        case 0:
            guard
                let name = vm.service?.packageInfo.name,
                let location = vm.service?.location.name
            else {
                return ""
            }
            
            return "\(name) • \(location)"
            
        case 3:
            return sshStatus
            
        default:
            return ""
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("General", systemImage: "gear", value: 0) {
                VDSServiceDetails(serviceID)
            }
            
            Tab("Protection", systemImage: "shield.lefthalf.filled", value: 1) {
                VDSProtection(serviceID)
            }
            
            Tab("History", systemImage: "clock", value: 2) {
                VDSServiceHistoryTab(serviceID)
            }
#if canImport(SwiftTerm) && canImport(NIOSSH)
            Tab("SSH", systemImage: "terminal", value: 3) {
                VDSSSHTab(credentials: $sshCredentials, logs: $logs, sshStatus: $sshStatus)
            }
#endif
        }
        .navigationTitle(title ?? "\(vm.service?.name ?? "")")
        .navSubtitle(subtitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .modifier(VDSServiceDetailsToolbarModifier(
            selectedTab: $selectedTab,
            pendingName: $pendingName,
            alertRename: $alertRename,
            alertChangePassword: $alertChangePassword,
            sheetReinstallOS: $sheetReinstallOS,
            sheetSSHCredentials: $sheetSSHCredentials,
            sheetSSHLogs: $sheetSSHLogs,
            serviceId: serviceID
        ))
        .environment(vm)
#if !os(visionOS)
        .sheet($sheetSSHCredentials) {
            NavigationStack {
                VDSSheetSSHCredentials(credentials: $sshCredentials)
            }
        }
        .sheet($sheetSSHLogs) {
            NavigationStack {
                VDSSheetSSHLogs($logs)
            }
        }
#endif
        .sheet($sheetReinstallOS) {
            NavigationStack {
                VDSReinstallSheet(serviceID)
            }
            .environment(vm)
        }
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
            await vm.changePassword(newPassword, for: serviceID)
            newPassword = ""
        }
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetailsTabView(1)
            .environment(DashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
