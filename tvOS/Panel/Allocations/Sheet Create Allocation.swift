import SwiftUI

struct SheetCreateAllocation: View {
    @Environment(AllocationVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(vm.categories) { category in
            Button(category.name) {
                assign(category.id)
            }
        }
        .navigationTitle("Create allocation")
        .foregroundStyle(.foreground)
        .frame(maxWidth: .infinity)
        .task {
            await vm.fetchCategories()
        }
    }
    
    private func assign(_ category: Int) {
        Task {
            await vm.assignAllocation(category) {
                dismiss()
            }
        }
    }
}

#Preview {
    SheetCreateAllocation()
        .environment(AllocationVM(""))
}
