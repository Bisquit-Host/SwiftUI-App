import SwiftUI

struct SheetCreateAllocation: View {
    @Environment(AllocationVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(vm.categories) { category in
            Button(category.name) {
                assignAllocation(category.id)
            }
        }
        .navigationTitle("Create allocation")
        .foregroundStyle(.foreground)
        .frame(maxWidth: .infinity)
        .task {
            vm.fetchCategories()
        }
    }
    
    private func assignAllocation(_ category: Int) {
        vm.assignAllocation(category) {
            dismiss()
        }
    }
}

#Preview {
    SheetCreateAllocation()
        .environment(AllocationVM(""))
}
