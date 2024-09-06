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
        VStack {
            Text("Hello, World!")
            
            if let apiKey = Keychain.load(key: "selectedApiKey") {
                Text("Selected API Key: \(apiKey.prefix(6))")
            }
            
            Button("Test") {
                vm.sendMessage("r2f")
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
