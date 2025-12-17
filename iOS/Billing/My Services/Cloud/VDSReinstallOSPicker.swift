import SwiftUI

struct VDSReinstallOSPicker: View {
    @Binding private var selectedOSId: Int?
    @Binding private var selectedFamilyId: Int?
    private let availableOSCategories: [CloudServiceOSCategory]
    
    init(_ selectedOSId: Binding<Int?>, selectedFamilyId: Binding<Int?>, from availableOSCategories: [CloudServiceOSCategory]) {
        _selectedOSId = selectedOSId
        _selectedFamilyId = selectedFamilyId
        self.availableOSCategories = availableOSCategories
    }
    
    private var availableOSItemsForSelectedFamily: [CloudServiceOSItem] {
        guard let selectedFamilyId, let family = availableOSCategories.first(where: { $0.id == selectedFamilyId }) else {
            return []
        }
        
        return family.os
            .filter(\.enabled)
            .sorted { ($0.version ?? "") < ($1.version ?? "") }
    }
    
    var body: some View {
        Picker("OS", selection: $selectedOSId) {
            if availableOSItemsForSelectedFamily.isEmpty {
                Text(selectedFamilyId == nil ? "Select OS Family" : "No OS Options")
                    .tag(nil as Int?)
            } else {
                ForEach(availableOSItemsForSelectedFamily) {
                    Text($0.version ?? "Unknown")
                        .tag($0.id)
                }
            }
        }
        .pickerStyle(.navigationLink)
        .disabled(selectedFamilyId == nil || availableOSItemsForSelectedFamily.isEmpty)
    }
}

//#Preview {
//    VDSReinstallOSPicker()
//        .darkSchemePreferred()
//}
