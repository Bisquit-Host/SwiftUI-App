import SwiftUI

struct TopbarGridButton: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 1)) {
                switch settings.designCode {
                case 0: settings.designCode = 1
                    //case 1: settings.designCode = 2
                default: settings.designCode = 0
                }
            }
        } label: {
            HStack(spacing: 2) {
                Text("Grid")
                    .title3(.semibold)
                    .rounded()
                    .padding(.leading)
                
                Image(systemName: settings.designCode == 0 ? "rectangle.grid.2x2.fill" : "rectangle.grid.1x2.fill")
                    .title(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 5)
                    .frame(width: 60, height: 60)
            }
            .frame(maxWidth: 160)
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    TopbarGridButton()
        .environmentObject(SettingsStorage())
}
