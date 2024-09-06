import SwiftUI
import Messages
import PteroNet

struct HomeView: View {
    @State private var vm: MessagesVM
    @Binding private var vc: MessagesViewController?
    
    init(_ vc: Binding<MessagesViewController?>) {
        _vc = vc
        self.vm = .init(vc.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .toolbar {
                Button("Test") {
                    vm.sendMessage("r2f")
                }
                .padding(.trailing)
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
