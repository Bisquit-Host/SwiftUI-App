import SwiftUI

struct PanelSidebarPowerButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    var isFilled = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.body)
                .frame(maxWidth: .infinity)
        }
        .frame(width: 42, height: 34)
        .frame(maxWidth: .infinity)
        .foregroundStyle(isFilled ? .white : tint)
        .background(isFilled ? tint : tint.opacity(0.12), in: .rect(cornerRadius: 10))
        .buttonStyle(.plain)
    }
}

#Preview {
    PanelSidebarPowerButton(title: "Start", systemImage: "play", tint: .green) {
    }
    .padding()
    .darkSchemePreferred()
}
