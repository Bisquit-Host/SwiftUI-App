import SwiftUI
import SwiftData
import PteroNet

struct SettingsAccountSection: View {
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetKeyStorage = false
    
    var body: some View {
        Section {
            if keys.count > 0 {
                Button("Switch account", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                    sheetKeyStorage = true
                }
            }
            
            Button {
                nav.clear()
                store.isApiKeyValid = false
                Keychain.delete(key: "selectedApiKey")
            } label: {
                Label {
                    Text("Log out")
                } icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    List {
        SettingsAccountSection()
    }
    .environment(NavState())
    .environmentObject(ValueStore())
}
