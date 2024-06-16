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
            vm.appear(settings.useBiometry, navState: navState)
            
            serverVM.fetchServers(settings.adminServerList)
        }
    }
    
    private var biometryView: some View {
        Label(vm.bioType, systemImage: vm.icon)
            .title2()
            .padding()
            .foregroundStyle(vm.colorButton)
            .background(.aliceblue.gradient, in: .capsule)
            .shadow(color: .aliceblue, radius: 10)
            .changeEffect(
                .spray(origin: .bottom) {
                    Image(.bitquit)
                        .resizable()
                        .frame(width: 50, height: 50)
                },
                value: vm.trigger
            )
    }
    
    private var noBiometryView: some View {
        Label("Smile", systemImage: "face.smiling.inverse")
            .title2()
            .padding()
            .foregroundStyle(vm.colorButton)
            .background(.aliceblue.gradient, in: .capsule)
            .shadow(color: .aliceblue, radius: 10)
    }
}

#Preview {
    AuthView()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
