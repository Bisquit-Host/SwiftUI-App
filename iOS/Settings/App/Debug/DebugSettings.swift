import SwiftUI
import PteroNet

#if canImport(ContactProvider)
import ContactProvider
#endif

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    @State private var confetti = ConfettiVM()
    
    var body: some View {
        List {
            DebugSettingsAppVersion()
            DebugSettingsDeviceAndSystem()
            
            Section {
                Toggle("Developer mode", isOn: $store.devMode)
                Toggle("Hide status bar", isOn: $store.hideStatusBar)
                Toggle("Hide server names", isOn: $store.hideServerNames)
            }
            
            DebugSettingsPushNotifications()
            DebugSettingsSystemAlerts()
            DebugSettingsTips()
            
            Section {
                Button("Clear all cookies", action: clearAllCookies)
            }
            
            Section("Effects") {
                Button("Spawn confetti", action: confetti.launchConfetti)
            }
            
            Section {
                NavigationLink {
                    DebugSettingsGamepad()
                } label: {
                    Label("Gamepad test", systemImage: "gamecontroller")
                }
            }
            
            Section("Contacts provider") {
                Toggle("Save contacts automatically", isOn: $store.contactsProviderEnabled)
                Button("Enable Extension", action: enableExtension)
            }
            
            Section("Metrics") {
                Toggle("Save metrics", isOn: $store.saveMetrics)
                
                NavigationLink {
                    MetricList()
                } label: {
                    Label("Saved metrics", systemImage: "doc.text.magnifyingglass")
                }
            }
            
            DebugSettingsFooter()
        }
        .navigationTitle("Debug")
        .scrollIndicators(.never)
        .overlay {
            ConfettiOverlay()
                .environment(confetti)
        }
    }
    
    private func enableExtension() {
        Task {
            do {
                try await ContactProviderManager().enable()
            } catch {
                print(error.localizedDescription)
            }
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
