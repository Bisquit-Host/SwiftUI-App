import SwiftUI

struct UpdateSheetButton: View {
    private let title: LocalizedStringKey
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .title3(.semibold, design: .rounded)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
        }
#if !os(visionOS)
        .buttonStyle(.glassProminent)
#endif
        .tint(.orange.opacity(0.5))
    }
}

//#Preview {
//    UpdateSheetButton()
//}
