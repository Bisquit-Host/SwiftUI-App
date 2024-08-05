import SwiftUI

struct NewConfigurationCard: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    @Namespace private var animation
    
    @State private var sheetBrowser = false
    
    var body: some View {
        Button {
            sheetBrowser = true
        } label: {
            if settings.designCode == 0 {
                VStack(spacing: 10) {
                    Image(systemName: "externaldrive.badge.plus")
                        .largeTitle()
                        .foregroundColor(.accentColor)
                        .matchedEffect("conf_icon", in: animation)
                    
                    Text("Configure a new server")
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .foregroundColor(.primary)
                        .matchedEffect("conf_text", in: animation)
                }
                .padding(5)
                .frame(minWidth: 170, maxWidth: 360, maxHeight: 360)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 32))
                
            } else {
                HStack {
                    Image(systemName: "externaldrive.badge.plus")
                        .largeTitle()
                        .foregroundColor(.accentColor)
                        .matchedEffect("conf_icon", in: animation)
                    
                    Text("Configure a new server")
                        .title2()
                        .foregroundColor(.primary)
                        .matchedEffect("conf_text", in: animation)
                }
                .frame(minWidth: 360, maxHeight: 150)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
            }
        }
        .sheet(isPresented: $sheetBrowser) {
            Browser()
        }
    }
}

#Preview {
    ServerListGrid([])
        .environment(ServerListVM())
        .environmentObject(SettingsStorage())
}
