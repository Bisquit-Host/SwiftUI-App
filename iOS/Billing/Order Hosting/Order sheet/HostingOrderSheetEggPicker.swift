import SwiftUI

struct HostingOrderSheetEggPicker: View {
    @Environment(NewOrderVM.self) private var vm
    
    private var eggsForSelection: [BillingHostingEgg] {
        vm.nests.first {
            $0.id == vm.selectedNestId
        }?.eggs ?? []
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Egg", selection: $vm.selectedEggId) {
            ForEach(eggsForSelection) {
                Text($0.name)
                    .tag($0.id)
            }
        }
    }
}

#Preview {
    HostingOrderSheetEggPicker()
}
