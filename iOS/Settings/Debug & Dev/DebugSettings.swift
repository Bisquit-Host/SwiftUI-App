import SwiftUI
import PteroNet
import ScrechKit

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
            
            if let pushToken = store.pushToken {
                Section("Push token") {
                    Text(pushToken)
                    
                    Button("Copy") {
                        Pasteboard.copy(pushToken)
                    }
                }
            }
            
            Section("System alerts") {
                Button("Copied") {
                    SystemAlert.copied()
                }
                
                Button("Network error") {
                    SystemAlert.networkError()
                }
                
                Button("Restored backup") {
                    SystemAlert.restored()
                }
                
                Button("Reinstalled server") {
                    SystemAlert.reinstalled()
                }
                
                Button("Changes saved") {
                    SystemAlert.changesSaved()
                }
                
                Button("Error (title & subtitle)") {
                    SystemAlert.error("Title", subtitle: "Subtitle")
                }
            }
            
            DebugSettingsTips()
            
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
            
            Section("Contacts provider") {
                Toggle("Save contacts automatically", isOn: $store.contactsProviderEnabled)
                
                Button("Enable Extension") {
                    enableExtension()
                }
            }
            
            Toggle("Test billing", isOn: $store.testBilling)
        }
        .navigationTitle("Debug")
        .scrollIndicators(.never)
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
    NavigationStack {
        DebugSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
