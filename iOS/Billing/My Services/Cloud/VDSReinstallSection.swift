import ScrechKit

struct VDSReinstallSheet: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var selectedFamilyId: Int?
    @State private var selectedOSId: Int?
    
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
                            selectedFamilyId: $selectedFamilyId,
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
        .onChange(of: selectedFamilyId) {
            setOSDefaultForSelectedFamily()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reinstall", systemImage: "plus.arrow.trianglehead.clockwise", role: .destructive, action: reinstall)
                    .tint(.orange)
                    .disabled(selectedOSId == nil || vm.isPerformingAction)
            }
        }
    }
    
    private func reinstall() {
        guard let selectedOSId else { return }
        
        Task {
            await vm.reinstall(osId: selectedOSId, serviceId: serviceId)
            dismiss()
        }
    }
    
    private var availableOSCategories: [CloudServiceOSCategory] {
        vm.osOptions
            .filter { $0.enabled && $0.os.contains(where: \.enabled) }
            .sorted {
                ($0.sortId ?? .max, $0.name) < ($1.sortId ?? .max, $1.name)
            }
    }
    
    private func availableOSItems(in category: CloudServiceOSCategory) -> [CloudServiceOSItem] {
        category.sortedOSItems
    }
    
    private func setDefaultSelectionsIfNeeded() {
        guard selectedFamilyId == nil || !availableOSCategories.contains(where: { $0.id == selectedFamilyId }) else {
            setOSDefaultForSelectedFamily()
            return
        }
        
        selectedFamilyId = availableOSCategories.first?.id
        setOSDefaultForSelectedFamily()
    }
    
    private func setOSDefaultForSelectedFamily() {
        guard let selectedFamilyId, let family = availableOSCategories.first(where: { $0.id == selectedFamilyId }) else {
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
