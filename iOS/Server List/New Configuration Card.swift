import SwiftUI

struct NewConfigurationCard: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    @Namespace private var animation
    
    var body: some View {
        if settings.designCode == 0 {
            VStack(spacing: 10) {
                Image(systemName: "externaldrive.badge.plus")
                    .largeTitle()
                    .foregroundColor(.accentColor)
                    .matchedEffect("conf_icon", in: animation)
                
                Text("Configure a new server")
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
                    .matchedEffect("conf_text", in: animation)
            }
            .padding(5)
            .frame(minWidth: 170, maxWidth: 360, maxHeight: 360)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 35))
            
        } else {
            HStack {
                Image(systemName: "externaldrive.badge.plus")
                    .largeTitle()
                    .foregroundColor(.accentColor)
                    .matchedEffect("conf_icon", in: animation)
                
                Text("Configure a new server")
                    .title2()
                    .matchedEffect("conf_text", in: animation)
            }
            .frame(minWidth: 360, maxHeight: 150)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
        }
    }
}

#Preview {
    ServerListGrid([])
        .environment(ServerListVM())
        .environmentObject(SettingsStorage())
}
