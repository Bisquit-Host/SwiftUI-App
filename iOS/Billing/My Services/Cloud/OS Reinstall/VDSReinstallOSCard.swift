import ScrechKit

struct VDSReinstallOSCard: View {
    let category: CloudServiceOSCategory
    
    @Binding private var selectedFamilyId: Int?
    @Binding private var selectedOSId: Int?
    
    @State private var displayedOSId: Int?
    
    init(category: CloudServiceOSCategory, selectedFamilyId: Binding<Int?>, selectedOSId: Binding<Int?>) {
        self.category = category
        _selectedFamilyId = selectedFamilyId
        _selectedOSId = selectedOSId
    }
    
    var body: some View {
        ZStack {
            Button(action: selectDisplayedOS) {
                Rectangle()
                    .fill(.background.opacity(0.001))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 14) {
                VStack(spacing: 14) {
                    VDSReinstallSectionOSLogo(category, size: 72)
                    
                    Text(category.name)
                        .headline()
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                }
                .allowsHitTesting(false)
                
                Menu {
                    ForEach(category.sortedOSItems) { item in
                        VDSReinstallOSVersionButton(item: item, isSelected: item.id == displayedOSId) {
                            displayedOSId = item.id
                            selectedFamilyId = category.id
                            selectedOSId = item.id
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(displayedOSVersion)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                            .secondary()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.secondary.opacity(0.08), in: .rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.primary.opacity(0.06), lineWidth: 1)
                    }
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded(selectDisplayedOS)
                )
                .tint(.primary)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: 188)
        .background(.background, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? .orange.opacity(0.6) : .primary.opacity(0.08), lineWidth: 1)
        }
        .task {
            setInitialVersion()
        }
        .onChange(of: selectedOSId) {
            syncSelectedVersionIfNeeded()
        }
    }
    
    private var isSelected: Bool {
        selectedFamilyId == category.id
    }
    
    private var displayedOSVersion: String {
        guard let displayedOSId, let item = category.sortedOSItems.first(where: { $0.id == displayedOSId }) else {
            return String(localized: "Select")
        }
        
        return item.version ?? String(localized: "Unknown")
    }
    
    private func selectDisplayedOS() {
        guard let displayedOSId else { return }
        
        selectedFamilyId = category.id
        selectedOSId = displayedOSId
    }
    
    private func setInitialVersion() {
        if let selectedOSId, category.sortedOSItems.contains(where: { $0.id == selectedOSId }) {
            displayedOSId = selectedOSId
            return
        }
        
        displayedOSId = category.sortedOSItems.first?.id
    }
    
    private func syncSelectedVersionIfNeeded() {
        guard let selectedOSId, category.sortedOSItems.contains(where: { $0.id == selectedOSId }) else {
            return
        }
        
        displayedOSId = selectedOSId
    }
}

extension CloudServiceOSCategory {
    var sortedOSItems: [CloudServiceOSItem] {
        os
            .filter(\.enabled)
            .sorted {
                ($0.version ?? "") > ($1.version ?? "")
            }
    }
}
