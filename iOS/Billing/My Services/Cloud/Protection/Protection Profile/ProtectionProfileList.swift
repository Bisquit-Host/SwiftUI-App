import SwiftUI

struct ProtectionProfileList: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @Binding private var editingProfile: VDSProtectionProfile?
    
    init(_ editingProfile: Binding<VDSProtectionProfile?>) {
        _editingProfile = editingProfile
    }
    
    var body: some View {
        ForEach(vm.profiles) {
            ProtectionProfileCard($0, editingProfile: $editingProfile)
        }
    }
}
