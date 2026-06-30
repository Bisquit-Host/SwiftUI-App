import ScrechKit

struct VDSReinstallSheet: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let serviceID: Int
    
    init(_ serviceID: Int) {
        self.serviceID = serviceID
    }
    
    @State private var selectedFamilyID: Int?
    @State private var selectedOSId: Int?
    @State private var confirmationReinstall = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(availableOSCategories) {
                        VDSReinstallOSCard(
                            category: $0,
                            selectedFamilyId: $selectedFamilyID,
                            selectedOSId: $selectedOSId
                        )
                    }
                }
            }
        }
        .navigationTitle("Reinstall OS")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .scenePadding(.horizontal)
        .task {
            setDefaultSelectionsIfNeeded()
        }
        .onChange(of: vm.osOptions) {
            setDefaultSelectionsIfNeeded()
        }
        .onChange(of: selectedFamilyID) {
            setOSDefaultForSelectedFamily()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reinstall", systemImage: "checkmark", role: .destructive) {
                    confirmationReinstall = true
                }
                .tint(.green)
                .disabled(selectedOSId == nil || vm.isPerformingAction)
            }
        }
        .alert("Reinstall OS", isPresented: $confirmationReinstall) {
            Button("Reinstall", role: .destructive, action: reinstall)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Reinstalling the operating system may delete files and reset settings. Back up your data before continuing")
        }
    }
    
    private func reinstall() {
        guard let selectedOSId else { return }
        
        Task {
            await vm.reinstall(osId: selectedOSId, serviceId: serviceID)
            dismiss()
        }
    }
    
    private var availableOSCategories: [CloudServiceOSCategory] {
        vm.osOptions
            .filter {
                $0.enabled && $0.os.contains(where: \.enabled)
            }
            .sorted {
                ($0.sortId ?? .max, $0.name) < ($1.sortId ?? .max, $1.name)
            }
    }
    
    private func availableOSItems(in category: CloudServiceOSCategory) -> [CloudServiceOSItem] {
        category.sortedOSItems
    }
    
    private func setDefaultSelectionsIfNeeded() {
        guard selectedFamilyID == nil || !availableOSCategories.contains(where: { $0.id == selectedFamilyID }) else {
            setOSDefaultForSelectedFamily()
            return
        }
        
        selectedFamilyID = availableOSCategories.first?.id
        setOSDefaultForSelectedFamily()
    }
    
    private func setOSDefaultForSelectedFamily() {
        guard let selectedFamilyID, let family = availableOSCategories.first(where: { $0.id == selectedFamilyID }) else {
            selectedOSId = nil
            return
        }
        
        let osItems = availableOSItems(in: family)
        
        guard let selectedOSId, osItems.contains(where: { $0.id == selectedOSId }) else {
            self.selectedOSId = osItems.first?.id
            return
        }
    }
}
