import SwiftUI

#if canImport(ContactProvider)
import ContactProvider
#endif

struct DebugSettings: View {
    @EnvironmentObject private var storage: SettingsStorage
    
    @State private var errorAlert = false
    
    var body: some View {
        List {
            Section("Contacts provider") {
                Toggle("Save contacts automatically", isOn: $storage.contactsProviderEnabled)
                
                Button("Enable Extension") {
                    enableExtension()
                }
            }
        }
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
        .environmentObject(SettingsStorage())
}
