import SwiftUI
import Messages
import PteroNet

struct HomeView: View {
    @StateObject private var store = ValueStore()
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
            .environmentObject(store)
            .environment(serverVm)
            //            .toolbarBackgroundVisibility(.visible)
        }
    }
}

//#Preview {
//    HomeView()
//        .darkSchemePreferred()
//}
