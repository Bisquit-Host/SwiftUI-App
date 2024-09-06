import SwiftUI
import PteroNet

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            if let apiKey = Keychain.load(key: "selectedApiKey") {
                Text("Selected API Key: \(apiKey.prefix(6))")
            }
            
            NavigationLink("1") {
                Image(.artwork)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
        }
    }
}

#Preview {
    HomeView()
}
