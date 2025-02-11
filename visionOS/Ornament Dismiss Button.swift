import SwiftUI

struct OrnamentDismissButton: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
#if os(visionOS)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                Button("Dismiss") {
                    dismiss()
                }
            }
#endif
    }
}

extension View {
    func ornamentDismissButton() -> some View {
        modifier(OrnamentDismissButton())
    }
}
