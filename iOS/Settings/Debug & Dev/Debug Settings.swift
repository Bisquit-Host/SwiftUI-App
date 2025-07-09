import SwiftUI
import PteroNet

#if canImport(ContactProvider)
import ContactProvider
#endif

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var errorAlert = false
    
    var body: some View {
        List {
            Section {
                Toggle("Developer mode", isOn: $store.devMode)
                
                Toggle("Hide status bar", isOn: $store.hideStatusBar)
                
                Toggle("Hide server names", isOn: $store.hideServerNames)
            }
            
            DebugSettingsTips()
            
            Section("Contacts provider") {
                Toggle("Save contacts automatically", isOn: $store.contactsProviderEnabled)
                
                Button("Enable Extension") {
                    enableExtension()
                }
            }
            
            Section {
                Button("Clear all cookies") {
                    clearAllCookies()
                }
            }
            
            Section {
                NavigationLink {
                    GamepadDebug()
                } label: {
                    Label("Gamepad test", systemImage: "gamecontroller")
                }
            }
        }
        .navigationTitle("Debug")
        .foregroundStyle(.foreground)
        .alert("Couldn't enable the extension", isPresented: $errorAlert) {}
    }
    
    private func enableExtension() {
        do {
            let manager = try ContactProviderManager()
            
            Task {
                try await manager.enable()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    DebugSettings()
        .environmentObject(ValueStore())
}
