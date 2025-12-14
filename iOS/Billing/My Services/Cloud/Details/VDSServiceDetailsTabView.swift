import ScrechKit

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    let serviceId: Int
    
    @State private var selectedTab = 0
    @State private var alertRename = false
    @State private var pendingName = ""
    
    private var title: LocalizedStringKey? {
        switch selectedTab {
        case 1: "Protection"
        case 2: "History"
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
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .toolbar {
            if selectedTab == 0 {
                if vm.isPerformingAction {
                    ProgressView()
                } else {
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
