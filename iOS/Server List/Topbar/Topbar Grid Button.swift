import SwiftUI

struct TopbarGridButton: View {
    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 1)) {
                switch settings.designCode {
                case 0:
                    settings.designCode = 1
                    
                    //case 1:
                    //settings.designCode = 2
                    
                default:
                    settings.designCode = 0
                }
            }
        } label: {
            let icon = settings.designCode == 0 ? "rectangle.grid.2x2.fill" : "rectangle.grid.1x2.fill"
            
            Image(systemName: icon)
        }
        .keyboardShortcut("L", modifiers: .option)
    }
}

#Preview {
    TopbarGridButton()
        .environmentObject(ValueStorage())
}
