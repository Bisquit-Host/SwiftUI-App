import SwiftUI

struct TopbarGridButton: View {
    @EnvironmentObject private var store: ValueStore
    
    private var icon: String {
        switch store.designCode {
        case 0: "rectangle.grid.1x2.fill"
        default: "rectangle.grid.2x2.fill"
        }
    }
    
    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 1)) {
                switch store.designCode {
                case 0:
                    store.designCode = 1
                    
                default:
                    store.designCode = 0
                }
            }
        } label: {
            Label("Grid layout", systemImage: icon)
        }
    }
}

#Preview {
    TopbarGridButton()
        .environmentObject(ValueStore())
}
