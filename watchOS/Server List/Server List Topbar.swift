import ScrechKit

struct ServerListTopbar: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
//    @State private var alertNetwork = false
    @State private var isRotating = false
    
    var body: some View {
        HStack {
            SFButton("wifi") {
                //alertNetwork = true
            }
            .foregroundStyle(.green)
            .symbolEffect(.variableColor.iterative)
            
            SFButton("arrow.triangle.2.circlepath") {
                vm.fetchServers(settings.adminServerList)
            }
            
            Button {
                navState.navigate(.toSettings)
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(.secondary)
                    .rotate(isRotating ? 360 : 0)
                    .animation(
                        .linear(duration: 60).repeatForever(autoreverses: false),
                        value: isRotating
                    )
            }
        }
        .title2(.bold)
        .onAppear {
            delay(0.1) {
                isRotating = true
            }
        }
    }
}

#Preview {
    ServerListTopbar()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
