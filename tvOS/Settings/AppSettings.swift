import ScrechKit
import SwiftData
import Kingfisher
import PteroNet

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetKeyStorage = false
    @State private var sheetGuide = false
    @State private var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    var body: some View {
        List {
            Button("Switch account", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                sheetKeyStorage = true
            }
            
            Button("API-key Creation") {
                sheetGuide = true
            }
            
            NavigationLink("Best places") {
                MapView()
            }
            
            ListLink("Configurations", icon: "externaldrive.badge.plus") {
                BrowserParent()
            }
            
            Section {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    dismiss()
                    navState.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .listStyle(.grouped)
        .sheet($sheetKeyStorage) {
            CloudKeys($apiKey)
        }
        .fullScreenCover($sheetGuide) {
            Guide()
                .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    NavigationStack {
        AppSettings()
    }
    .environmentObject(ValueStore())
    .environment(NavState())
}
