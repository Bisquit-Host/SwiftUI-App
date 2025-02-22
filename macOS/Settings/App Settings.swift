import ScrechKit
import PteroNet
import LaunchAtLogin

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            LaunchAtLogin.Toggle()
            
            Button("Log out") {
                main {
                    navState.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
                
                dismiss()
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    AppSettings()
}
