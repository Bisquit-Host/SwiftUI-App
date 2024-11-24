import ScrechKit
import Kingfisher

struct AuthView: View {
    @State private var vm = AuthVM()
//    @Environment(NavState.self) private var navState
//    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        Home()
//        VStack {
//            Text("Auth View")
//        }
//        .task {
////            try? await Task.sleep(for: .seconds(1))
//            vm.appear(settings.useBiometry, navState: navState)
//        }
    }
}

#Preview {
    AuthView()
//        .environment(NavState())
//        .environmentObject(ValueStorage())
}
