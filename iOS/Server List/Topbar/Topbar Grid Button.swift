import SwiftUI

struct TopbarGridButton: View {
    @EnvironmentObject private var settings: ValueStorage
    
    private var icon: String {
        switch settings.designCode {
        case 0: "rectangle.grid.1x2.fill"
        default: "rectangle.grid.2x2.fill"
        }
    }
    
    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 1)) {
                switch settings.designCode {
                case 0:
                    settings.designCode = 1
                    
                default:
                    settings.designCode = 0
                }
            }
        } label: {
            Label("Grid layout", systemImage: icon)
        }
    }
}

#Preview {
    TopbarGridButton()
        .environmentObject(ValueStorage())
}
