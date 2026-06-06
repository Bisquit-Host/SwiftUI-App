import SwiftUI

struct HostingOrderSheetOSPicker: View {
    @Environment(NewOrderVM.self) private var vm
    
    private var osItems: [(id: Int, title: String)] {
        vm.osCategories.flatMap { category in
            category.os.map { item in
                let version = item.version.map { " \($0)" } ?? ""
                return (id: item.id, title: category.name + version)
            }
        }
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        if vm.isLoadingOptions && osItems.isEmpty {
            ProgressView()
        }
        
        Picker("OS", selection: $vm.selectedOSId) {
            ForEach(osItems, id: \.id) { // requires id
                Text($0.title)
                    .tag($0.id)
            }
        }
    }
}

#Preview {
    HostingOrderSheetOSPicker()
        .darkSchemePreferred()
}
