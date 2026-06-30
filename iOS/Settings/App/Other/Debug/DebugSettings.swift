import SwiftUI
import Calagopus

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    @State private var confetti = ConfettiVM()
    
    @State private var updateSheet = false
    
    var body: some View {
        List {
            DebugSettingsAppVersion()
            DebugSettingsDeviceAndSystem()
            
            Section {
                Toggle("Dev mode", isOn: $store.devMode)
#if os(iOS)
                Toggle("Hide status bar", isOn: $store.hideStatusBar)
#endif
                Toggle("Hide server names", isOn: $store.hideServerNames)
            }
            
            DebugSettingsPushNotifications()
            DebugSettingsSystemAlerts()
            DebugSettingsAttesterCheck()
            DebugSettingsTips()
            
            Section("Updates") {
                Button("Present update sheet", systemImage: "arrow.down.circle") {
                    updateSheet = true
                }
            }
            
            Section("Cache") {
                NavigationLink {
                    CacheList()
                } label: {
                    Label("View cache", systemImage: "internaldrive")
                }
            }
            
            Section {
                Button("Clear all cookies", action: clearAllCookies)
            }
            
            Section {
                Button("Spawn confetti", action: confetti.launchConfetti)
                    .disabled(!store.bigAssAnimations)
            } header: {
                Text("Effects")
            } footer: {
                if !store.bigAssAnimations {
                    Text("Animations are disabled")
                }
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
        .fullScreenCover($updateSheet) {
            UpdateSheet()
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
