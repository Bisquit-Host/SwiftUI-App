import SwiftUI

struct SheetCreateAllocation: View {
    @Environment(AllocationVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory = -1
    
    var body: some View {
        ScrollView {
            ForEach(vm.categories) {
                SheetCreateAllocationCard($selectedCategory, category: $0)
            }
        }
        .navigationTitle("Create allocation")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .padding(.horizontal)
        .task {
            await vm.fetchCategories()
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                Button("Create") {
                    assignAllocation()
                }
                .disabled(selectedCategory == -1)
            }
        }
    }
    
    private func assignAllocation() {
        Task {
            await vm.assignAllocation(selectedCategory) {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SheetCreateAllocation()
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
