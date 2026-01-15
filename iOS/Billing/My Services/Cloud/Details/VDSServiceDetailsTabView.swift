import ScrechKit
import BisquitoNet

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
                VDSSSHTab(credentials: $sshCredentials, logs: $logs, sshStatus: $sshStatus)
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
                VDSSheetSSHCredentials(credentials: $sshCredentials)
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
