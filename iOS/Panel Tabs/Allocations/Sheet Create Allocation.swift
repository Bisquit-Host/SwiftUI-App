import SwiftUI

struct SheetCreateAllocation: View {
    @Environment(AllocationVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory = -1
    
    var body: some View {
        List {
            Picker("", selection: $selectedCategory) {
                ForEach(vm.categories) { category in
                    Text(category.name)
                        .tag(category.id)
                }
            }
            .pickerStyle(.inline)
            .transparentSection()
            
            Section {
                Button("Create") {
                    vm.assignAllocation(selectedCategory) {
                        dismiss()
                    }
                }
                .semibold()
                .foregroundStyle(.foreground)
                .disabled(selectedCategory == -1)
            }
            .transparentSection()
        }
        .navigationTitle("Create allocation")
        .transparentList()
        .scrollIndicators(.never)
        .task {
            vm.fetchCategories()
        }
    }
}

#Preview {
    SheetCreateAllocation()
        .environment(AllocationVM(""))
}
