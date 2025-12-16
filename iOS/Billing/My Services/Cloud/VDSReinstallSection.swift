import SwiftUI
import Kingfisher
#warning("Subviews")
struct VDSReinstallSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    let serviceId: Int
    
    @State private var selectedFamilyId: Int?
    @State private var selectedOSId: Int?
    
    var body: some View {
        VDSSectionCard("Reinstall OS") {
            Picker("OS Family", selection: $selectedFamilyId) {
                ForEach(availableOSCategories) { category in
                    HStack(spacing: 12) {
                        osFamilyLogo(category)
                        
                        Text(category.name)
                    }
                    .tag(category.id as Int?)
                }
            }
            .pickerStyle(.navigationLink)
            
            Picker("OS", selection: $selectedOSId) {
                if let selectedFamilyId, let family = availableOSCategories.first(where: { $0.id == selectedFamilyId }) {
                    ForEach(availableOSItems(in: family)) {
                        Text($0.version ?? "Unknown")
                            .tag($0.id as Int?)
                    }
                }
            }
            .pickerStyle(.navigationLink)
            
            Button(role: .destructive) {
                if let osId = selectedOSId {
                    Task {
                        await vm.reinstall(osId: osId, serviceId: serviceId)
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
        .onChange(of: vm.osOptions) { _, _ in
            setDefaultSelectionsIfNeeded()
        }
        .onChange(of: selectedFamilyId) { _, _ in
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
    
    @ViewBuilder
    private func osFamilyLogo(_ category: CloudServiceOSCategory) -> some View {
        if let urlString = category.logoUrl, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFit()
                .frame(24)
                .clipShape(.rect(cornerRadius: 6))
        } else {
            Image(systemName: "questionmark.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(24)
                .secondary()
        }
    }
}
