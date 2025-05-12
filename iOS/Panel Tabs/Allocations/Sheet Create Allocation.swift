import SwiftUI

struct SheetCreateAllocation: View {
    @Environment(AllocationVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory = -1
    
    var body: some View {
        List {
            Picker("Category", selection: $selectedCategory) {
                Text("Not selected")
                    .secondary()
                    .tag(-1)
                
                ForEach(vm.categories) { category in
                    Text(category.name)
                        .tag(category.id)
                }
            }
            .pickerStyle(.inline)
            
            Section {
                Button("Create") {
                    vm.assignAllocation(selectedCategory) {
                        dismiss()
                    }
                }
                .foregroundStyle(.foreground)
                .disabled(selectedCategory == -1)
            }
        }
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
