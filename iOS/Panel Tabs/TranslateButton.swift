import SwiftUI

struct TranslateButton: View {
    @Binding private var showTranslation: Bool
    private let text: String
    
    init(_ showTranslation: Binding<Bool>, text: String) {
        _showTranslation = showTranslation
        self.text = text
    }
    
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
    TranslateButton(.constant(false), text: "Preview")
        .padding()
}
