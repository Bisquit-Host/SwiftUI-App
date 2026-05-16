import SwiftUI

struct UpdateSheetBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            [.orange.opacity(0.35), .orange.opacity(0.5), .orange.opacity(0.4)]
        } else {
            [.orange.opacity(0.7), .orange, .orange.opacity(0.9)]
        }
    }
    
    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

#Preview {
    UpdateSheetBackground()
}
