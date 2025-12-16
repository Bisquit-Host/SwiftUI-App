import SwiftUI

struct LoginStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 50)
            .background(.primary.opacity(0.04), in: .capsule)
            .overlay {
                Capsule()
                    .stroke(.primary.opacity(0.05), lineWidth: 1)
            }
    }
}

extension View {
    func loginButtonStyle() -> some View {
        modifier(LoginStyleModifier())
    }
}
