import SwiftUI

struct TranslateButton: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    @State private var sheetTranslation = false
    
    var body: some View {
        Button("Translate", systemImage: "translate") {
            sheetTranslation = true
        }
        .labelStyle(.iconOnly)
        .disabled(text.isEmpty)
        .fixedSize()
        .translationPresentation(isPresented: $sheetTranslation, text: project.description)
    }
}

#Preview {
    TranslateButton("Preview")
        .padding()
}
