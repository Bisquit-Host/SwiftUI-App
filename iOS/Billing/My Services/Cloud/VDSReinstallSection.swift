import SwiftUI

struct VDSReinstallSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var selectedFamilyId: Int?
    @State private var selectedOSId: Int?
    
    var body: some View {
        ServiceSectionCard("Reinstall OS") {
            VDSReinstallOSFamilyPicker($selectedFamilyId, from: availableOSCategories)
            VDSReinstallOSPicker($selectedOSId, selectedFamilyId: $selectedFamilyId, from: availableOSCategories)
            
            Button(role: .destructive) {
                if let selectedOSId {
                    Task {
                        await vm.reinstall(osId: selectedOSId, serviceId: serviceId)
                    }
                }
            } label: {
                Text("Reinstall")
                    .frame(maxWidth: .infinity)
            }
            .disabled(selectedOSId == nil || vm.isPerformingAction)
        }
        .task {
            setDefaultSelectionsIfNeeded()
        }
        .onChange(of: vm.osOptions) {
            setDefaultSelectionsIfNeeded()
        }
        .onChange(of: selectedFamilyId) {
            setOSDefaultForSelectedFamily()
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
        category.os
            .filter(\.enabled)
            .sorted { ($0.version ?? "") < ($1.version ?? "") }
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
