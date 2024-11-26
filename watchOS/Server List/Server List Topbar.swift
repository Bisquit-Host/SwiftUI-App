import ScrechKit

struct ServerListTopbar: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: ValueStorage
    
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
            .background(.ultraThinMaterial)
            
            Button {
                navState.navigate(.toSettings)
            } label: {
                Image(systemName: "gear")
                    .secondary()
                    .rotate(isRotating ? 360 : 0)
                    .animation(
                        .linear(duration: 60).repeatForever(autoreverses: false),
                        value: isRotating
                    )
            }
            .background(.ultraThinMaterial)
        }
        .title2(.bold)
        .task {
            isRotating = true
        }
    }
}

#Preview {
    ServerListTopbar()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStorage())
}
