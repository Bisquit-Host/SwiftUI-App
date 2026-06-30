import SwiftUI

struct MinecraftCatalogDescriptionTranslateButton: View {
    let text: String
    
    @Binding var showTranslation: Bool
    
    var body: some View {
        Button("Translate", systemImage: "translate") {
            showTranslation = true
        }
        .labelStyle(.iconOnly)
        .disabled(text.isEmpty)
        .fixedSize()
    }
}

#Preview {
    MinecraftCatalogDescriptionTranslateButton(
        text: "Preview",
        showTranslation: .constant(false)
    )
    .padding()
}
