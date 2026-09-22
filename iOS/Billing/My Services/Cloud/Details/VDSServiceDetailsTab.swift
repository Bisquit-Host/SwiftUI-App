import ScrechKit

struct VDSServiceDetailsTab: View {
    @State private var vm = VDSServiceDetailsVM()
    @State private var protectionVM = VDSProtectionVM()
    
    private let service: CloudServiceSummary
    
    init(_ service: CloudServiceSummary) {
        self.service = service
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
            let name = vm.service?.packageInfo.name ?? service.packageName
            let location = vm.service?.location.name ?? service.locationName
            
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
                VDSServiceDetails(service.id)
            }
            
            Tab("Protection", systemImage: "shield.lefthalf.filled", value: 1) {
                VDSProtection(service.id)
            }
            
            Tab("History", systemImage: "clock", value: 2) {
                VDSServiceHistoryTab(service.id)
            }
            
            Tab("SSH", systemImage: "terminal", value: 3) {
                VDSSSHTab(credentials: $sshCredentials, logs: $logs, sshStatus: $sshStatus)
            }
        }
        .environment(protectionVM)
        .navigationTitle(title ?? "\(vm.service?.name ?? service.name)")
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
            serviceId: service.id
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
                VDSReinstallSheet(service.id)
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
            await vm.changePassword(newPassword, for: service.id)
            newPassword = ""
        }
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetailsTab(CloudServiceSummary(
            id: 1,
            name: "Cloud server",
            price: 0,
            autorenew: false,
            state: .active,
            allowSuspend: false,
            allowDelete: false,
            createdAt: nil,
            expiresAt: nil,
            packageId: 1,
            packageName: "VDS",
            locationId: 1,
            locationName: "Amsterdam",
            locationFlagUrl: nil,
            system: nil,
            ip: nil,
            locationInfo: ServiceLocationSummary(name: "Amsterdam", flagUrl: nil),
            packageInfo: ServiceSummaryPackage(name: "VDS", bonusBalanceAllowed: nil, windowsAllowed: nil)
        ))
            .environment(DashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
