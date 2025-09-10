import SwiftUI

struct InfoTabCustomizationButton: View {
    @Binding private var sheetCustomization: Bool
    
    init(_ sheetCustomization: Binding<Bool>) {
        _sheetCustomization = sheetCustomization
    }
    
    var body: some View {
        Button("Customize & Reorder") {
            sheetCustomization = true
        }
        .semibold()
        .secondary()
        .foregroundStyle(.foreground)
        .padding(.vertical, 10)
    }
}

#Preview {
    InfoTabCustomizationButton(.constant(false))
}
