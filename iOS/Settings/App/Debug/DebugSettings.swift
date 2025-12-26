import SwiftUI
import PteroNet
import Vortex

#if canImport(ContactProvider)
import ContactProvider
#endif

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    @State private var confettiTrigger = 0
    @State private var isConfettiVisible = false
    @State private var confettiTask: Task<Void, Never>?
    
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
                Button("Spawn confetti", action: launchConfetti)
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
            confettiOverlay
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
    
    private var confettiOverlay: some View {
        VortexViewReader { proxy in
            VortexView(makeConfettiSystem()) {
                Rectangle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .tag("square")
                
                Circle()
                    .fill(.white)
                    .frame(width: 16)
                    .tag("circle")
            }
            .onChange(of: confettiTrigger) {
                spawnConfetti(using: proxy)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func launchConfetti() {
        confettiTask?.cancel()
        
        if !isConfettiVisible {
            isConfettiVisible = true
            confettiTrigger += 1
        } else {
            confettiTrigger += 1
        }
        
        confettiTask = Task {
            try? await Task.sleep(for: .seconds(4.5))
            
            await MainActor.run {
                isConfettiVisible = false
            }
        }
    }
    
    private func spawnConfetti(using proxy: VortexProxy) {
        for _ in 0..<5 {
            let x = Double.random(in: 0.2...0.8)
            let y = Double.random(in: 0.2...0.8)
            proxy.particleSystem?.position = [x, y]
            proxy.burst()
        }
    }
    
    private func makeConfettiSystem() -> VortexSystem {
        let system = VortexSystem.confetti.makeUniqueCopy()
        system.burstCount = 50
        
        return system
    }
}

#Preview {
    NavigationStack {
        DebugSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
