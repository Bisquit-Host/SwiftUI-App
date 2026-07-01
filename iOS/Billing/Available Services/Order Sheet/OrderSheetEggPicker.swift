import SwiftUI

struct OrderSheetEggPicker: View {
    @Environment(NewOrderVM.self) private var vm
    
    private let category: BillingHostingCategory
    
    init(_ category: BillingHostingCategory = .bot) {
        self.category = category
    }
    
    private var eggsForSelection: [BillingHostingEgg] {
        vm.nests.first {
            $0.id == vm.selectedNestID
        }?.eggs ?? []
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Egg", selection: $vm.selectedEggID) {
            if category == .bot {
                Text("-")
                    .tag(0)
            }
            
            ForEach(eggsForSelection) {
                Text($0.name)
                    .tag($0.id)
            }
        }
    }
}

#Preview {
    OrderSheetEggPicker()
}
