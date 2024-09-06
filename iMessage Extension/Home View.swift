import SwiftUI
import Messages
import PteroNet

struct HomeView: View {
    @StateObject private var settings = SettingsStorage()
    @State private var serverVm = ServerListVM()
    @State private var vm: MessagesVM
    @Binding private var vc: MessagesViewController?
    
    init(_ vc: Binding<MessagesViewController?>) {
        _vc = vc
        self.vm = .init(vc.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ServerList()
            }
            .environmentObject(settings)
            .environment(serverVm)
//            .toolbar {
//                Button("Test") {
//                    vm.sendMessage("r2f")
//                }
//                .padding(.trailing)
//            }
        }
    }
}

//#Preview {
//    HomeView()
//}
