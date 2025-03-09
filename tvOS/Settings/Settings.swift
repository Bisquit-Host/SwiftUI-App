import ScrechKit
import SwiftData
import Kingfisher
import PteroNet

struct Settings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetKeyStorage = false
    @State private var sheetGuide = false
    @State private var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    var body: some View {
        List {
            Button {
                sheetKeyStorage = true
            } label: {
                Label("Switch Account", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            
            Button("API-key Creation") {
                sheetGuide = true
            }
            
#warning("tvOS: Map")
            //                NavigationLink("Map") {
            //                    MapView()
            //                }
            
            ListLink("Configurations", icon: "externaldrive.badge.plus") {
                BrowserParent()
            }
            
            Section {
                Button(role: .destructive) {
                    main {
                        dismiss()
                        navState.clear()
                        store.isApiKeyValid = false
                        Keychain.delete(key: "selectedApiKey")
                    }
                } label: {
                    Text("\(Image(systemName: "rectangle.portrait.and.arrow.right")) Log out")
                }
            }
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .listStyle(.grouped)
        .sheet($sheetKeyStorage) {
            CloudKeys($apiKey)
        }
        .sheet($sheetGuide) {
            Guide()
        }
    }
}

#Preview {
    Settings()
        .environmentObject(ValueStore())
}
