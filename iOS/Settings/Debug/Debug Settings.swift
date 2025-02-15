import SwiftUI
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
                Toggle("Hide status bar", isOn: $store.hideStatusBar)
            }
            
            Section {
                Button {
                    Tips.showAllTipsForTesting()
                } label: {
                    Label("Show all tips", systemImage: "lightbulb.max")
                        .foregroundStyle(.yellow)
                }
            }
            
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
        }
        .alert("Couldn't enable the extension", isPresented: $errorAlert) {}
    }
    
    private func clearAllCookies() {
        guard let cookieStorage = HTTPCookieStorage.shared.cookies else {
            return
        }
        
        for cookie in cookieStorage {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
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
