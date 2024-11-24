import SwiftUI
import TipKit

#if canImport(ContactProvider)
import ContactProvider
#endif

struct DebugSettings: View {
    @EnvironmentObject private var storage: ValueStorage
    
    @State private var errorAlert = false
    
    var body: some View {
        List {
            Button {
                Tips.showAllTipsForTesting()
            } label: {
                Label("Show all tips", systemImage: "lightbulb.max")
                    .foregroundStyle(.yellow)
            }
            
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
        .environmentObject(ValueStorage())
}
