import SwiftUI

struct OrderSheetNestPicker: View {
    @Environment(NewOrderVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Nest", selection: $vm.selectedNestID) {
            ForEach(vm.nests) {
                Text($0.name)
                    .tag($0.id)
            }
        }
    }
}

//#Preview {
//    OrderSheetNestPicker()
//        .darkSchemePreferred()
//}
