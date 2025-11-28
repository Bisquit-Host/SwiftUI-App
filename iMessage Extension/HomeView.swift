import SwiftUI
import Messages
import PteroNet

struct HomeView: View {
    @StateObject private var store = ValueStore()
    @State private var serverVM = ServerListVM()
    @State private var vm: MessagesVM
    
    @Binding private var vc: MessagesViewController?
    
    init(_ vc: Binding<MessagesViewController?>) {
        _vc = vc
        vm = MessagesVM(vc.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ServerList()
            }
            .environmentObject(store)
            .environment(serverVM)
            //            .toolbarBackgroundVisibility(.visible)
        }
    }
}

//#Preview {
//    HomeView()
//        .darkSchemePreferred()
//}
