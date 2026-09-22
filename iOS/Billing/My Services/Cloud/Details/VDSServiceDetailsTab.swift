import ScrechKit

struct VDSServiceDetailsTab: View {
    @State private var vm = VDSServiceDetailsVM()
    
    private let serviceID: Int
    private let name: String
    private let packageName: String
    private let locationName: String
    
    init(_ serviceID: Int, name: String, packageName: String, locationName: String) {
        self.serviceID = serviceID
        self.name = name
        self.packageName = packageName
        self.locationName = locationName
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
            let name = vm.service?.packageInfo.name ?? packageName
            let location = vm.service?.location.name ?? locationName
            
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
            
            Tab("SSH", systemImage: "terminal", value: 3) {
                VDSSSHTab(credentials: $sshCredentials, logs: $logs, sshStatus: $sshStatus)
            }
        }
        .navigationTitle(title ?? "\(vm.service?.name ?? name)")
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
        VDSServiceDetailsTab(1, name: "Cloud server", packageName: "VDS", locationName: "Amsterdam")
            .environment(DashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
