import SwiftUI

struct MinecraftToolsPagination: View {
    let currentPage: Int
    let totalPages: Int
    let isLoading: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            Text("Page \(currentPage) of \(totalPages)")
                .secondary()
            
            Spacer()
            
            Button("Previous", action: onPrevious)
                .disabled(currentPage <= 1 || isLoading)
            
            Button("Next", action: onNext)
                .disabled(currentPage >= totalPages || isLoading)
        }
        .footnote()
        .padding(.top, 5)
        .tint(.primary)
    }
}

#Preview {
    MinecraftToolsPagination(
        currentPage: 1,
        totalPages: 3,
        isLoading: false,
        onPrevious: {},
        onNext: {}
    )
}
