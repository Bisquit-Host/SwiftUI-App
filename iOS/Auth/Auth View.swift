import ScrechKit

struct AuthView: View {
    @State private var vm = AuthVM()
    @Environment(ServerListVM.self) private var serverVM
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    private let bounds = UIScreen.main.bounds
    
    var body: some View {
        VStack {
            if settings.useBiometry {
                biometryView
            } else {
                noBiometryView
            }
        }
        .navigationBarBackButtonHidden()
        .frame(width: bounds.width, height: bounds.height)
        .background(AuthBackground())
        .ignoresSafeArea()
        .task {
            serverVM.fetchServers(settings.adminServerList)
            
            vm.appear(
                settings.useBiometry,
                navState: navState
            )
        }
    }
    
    private var biometryView: some View {
        Label(vm.bioType, systemImage: vm.icon)
            .title2()
            .padding()
            .foregroundStyle(vm.colorButton)
            .background(.aliceblue.gradient, in: .capsule)
            .shadow(color: .aliceblue, radius: 10)
    }
    
    private var noBiometryView: some View {
        Label("Smile", systemImage: "face.smiling.inverse")
            .title2()
            .padding()
            .foregroundStyle(vm.colorButton)
            .background(.aliceblue.gradient,
                        in: .capsule
            )
            .shadow(color: .aliceblue, radius: 10)
    }
}

#Preview {
    AuthView()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
