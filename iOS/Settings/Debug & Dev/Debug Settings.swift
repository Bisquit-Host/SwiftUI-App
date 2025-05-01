import SwiftUI
import PteroNet
import TipKit

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
            .transparentSection()
            
            Section {
                Button {
                    Tips.showAllTipsForTesting()
                } label: {
                    Label("Show all tips", systemImage: "lightbulb.max")
                        .foregroundStyle(.yellow)
                }
            }
            .transparentSection()
            
            Section("Contacts provider") {
                Toggle("Save contacts automatically", isOn: $store.contactsProviderEnabled)
                
                Button("Enable Extension") {
                    enableExtension()
                }
            }
            .transparentSection()
            
            Section {
                Button("Clear all cookies") {
                    clearAllCookies()
                }
            }
            .transparentSection()
            
            Section {
                NavigationLink("Gamepad Test") {
                    GamepadDebug()
                }
            }
        }
        .transparentList()
        .alert("Couldn't enable the extension", isPresented: $errorAlert) {}
    }
    
    private func enableExtension() {
        if #available(iOS 18, *) {
            do {
                let manager = try ContactProviderManager()
                
                Task {
                    try await manager.enable()
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            errorAlert = true
        }
    }
}

#Preview {
    DebugSettings()
        .environmentObject(ValueStore())
}
