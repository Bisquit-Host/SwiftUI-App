import SwiftUI

struct ProtectionProfileList: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    var body: some View {
        ForEach(vm.profiles) {
            ProtectionProfileCard($0)
        }
    }
}
