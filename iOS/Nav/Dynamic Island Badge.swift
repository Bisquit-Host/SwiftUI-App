import SwiftUI

struct DynamicIslandBadge: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(.bisquit)
                .resizable()
                .frame(20)
                .shadow(color: .black.opacity(0.5), radius: 2)
            
            Text("Bisquit.Host")
                .semibold()
        }
        .footnote()
        .frame(width: 120, height: 32)
        .background(.orange.gradient)
        .foregroundStyle(.white.gradient)
        .clipShape(.capsule)
        .padding(.top, 15)
        .ignoresSafeArea()
    }
}

#Preview {
    DynamicIslandBadge()
        .darkSchemePreferred()
}
