import SwiftUI

struct WideButton: View {
    private let title: LocalizedStringKey
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .semibold()
                .frame(height: 32)
                .frame(maxWidth: .infinity)
                .padding(5)
        }
        .buttonStyle(.glass)
    }
}

//#Preview {
//    WideButton()
//}
