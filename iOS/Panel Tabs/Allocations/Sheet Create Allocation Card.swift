import SwiftUI
import PteroNet

struct SheetCreateAllocationCard: View {
    @Binding private var selectedCategory: Int
    private let category: AllocationCategory
    
    init(
        _ selectedCategory: Binding<Int>,
        category: AllocationCategory
    ) {
        _selectedCategory = selectedCategory
        self.category = category
    }
    
    var body: some View {
        Button {
            selectedCategory = category.id
        } label: {
            Text(category.name)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    .ultraThinMaterial.opacity(selectedCategory == category.id ? 0 : 1),
                    in: .rect(cornerRadius: 16)
                )
                .background(
                    .blue.opacity(selectedCategory == category.id ? 1 : 0),
                    in: .rect(cornerRadius: 16)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
        }
        .foregroundStyle(.foreground)
    }
}

//#Preview {
//    SheetCreateAllocationCard()
//}
