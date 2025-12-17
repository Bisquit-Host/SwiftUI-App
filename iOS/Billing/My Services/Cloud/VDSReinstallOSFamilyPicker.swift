import SwiftUI

struct VDSReinstallOSFamilyPicker: View {
    @Binding private var selectedFamilyId: Int?
    private let availableOSCategories: [CloudServiceOSCategory]
    
    init(_ selectedFamilyId: Binding<Int?>, from availableOSCategories: [CloudServiceOSCategory]) {
        _selectedFamilyId = selectedFamilyId
        self.availableOSCategories = availableOSCategories
    }
    
    var body: some View {
        HStack {
            Text("OS Family")
            
            Spacer()
            
            Picker("OS Family", selection: $selectedFamilyId) {
                ForEach(availableOSCategories) { category in
                    HStack(spacing: 12) {
                        VDSReinstallSectionOSLogo(category)
                        
                        Text(category.name)
                    }
                    .tag(category.id)
                }
            }
            .tint(.primary)
        }
    }
}

//#Preview {
//    VDSReinstallOSFamilyPicker()
//        .darkSchemePreferred()
//}
