import SwiftUI

struct SheetCreateAllocation: View {
    @Environment(AllocationVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory = -1
    
    var body: some View {
        ScrollView {
            ForEach(vm.categories) { category in
                let background: Material = selectedCategory == category.id ? .ultraThickMaterial : .ultraThinMaterial
                
                Button {
                    selectedCategory = category.id
                } label: {
                    Text(category.name)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(background.opacity(0.5), in: .rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray.opacity(0.25), lineWidth: 1)
                        }
                }
                .foregroundStyle(.foreground)
            }
            
            Button {
                assignAllocation()
            } label: {
                Text("Create")
                    .semibold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.green.opacity(0.25), in: .rect(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.green.opacity(0.5), lineWidth: 1)
                    }
            }
            .disabled(selectedCategory == -1)
            .padding(.top)
            .foregroundStyle(.foreground)
        }
        .navigationTitle("Create allocation")
        .scrollIndicators(.never)
        .padding(.horizontal)
        .task {
            await vm.fetchCategories()
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
