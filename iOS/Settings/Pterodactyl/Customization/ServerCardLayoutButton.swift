import SwiftUI

struct ServerCardLayoutButton: View {
    @State private var sheetServerCardLayout = false
    
    var body: some View {
        GlassyActionCard("Server card layout", icon: "externaldrive", tint: .blue) {
            sheetServerCardLayout = true
        }
        .foregroundStyle(.foreground)
        .sheet($sheetServerCardLayout) {
            NavigationStack {
                ServerCardLayout()
            }
        }
    }
}
