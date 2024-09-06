import SwiftUI
import PteroNet

struct HomeView: View {
    @State private var vm = MessagesVM()
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            if let apiKey = Keychain.load(key: "selectedApiKey") {
                Text("Selected API Key: \(apiKey.prefix(6))")
            }
            
            Button("Test") {
                vm.sendMessage()
            }
        }
    }
}

#Preview {
    HomeView()
}
