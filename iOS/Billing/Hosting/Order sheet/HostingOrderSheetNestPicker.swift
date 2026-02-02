import SwiftUI

struct HostingOrderSheetNestPicker: View {
    @Environment(NewOrderVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Nest", selection: $vm.selectedNestId) {
            ForEach(vm.nests) {
                Text($0.name)
                    .tag($0.id)
            }
        }
    }
}

//#Preview {
//    HostingOrderSheetNestPicker()
//        .darkSchemePreferred()
//}
