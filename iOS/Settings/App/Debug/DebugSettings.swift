import SwiftUI
import PteroNet
import Vortex

#if canImport(ContactProvider)
import ContactProvider
#endif

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    @State private var fireworkBursts: [FireworkBurst] = []
    @State private var fireworkTask: Task<Void, Never>?
    
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
                Button("Launch fireworks", action: launchFireworks)
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
            if !fireworkBursts.isEmpty {
                fireworksOverlay
            }
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
    
    private var fireworksOverlay: some View {
        ZStack {
            ForEach(fireworkBursts) { burst in
                VortexView(burst.system) {
                    Circle()
                        .fill(.white)
                        .frame(width: 32)
                        .blur(radius: 5)
                        .blendMode(.plusLighter)
                        .tag("circle")
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func launchFireworks() {
        fireworkTask?.cancel()
        fireworkBursts = (0..<5).map { _ in
            FireworkBurst(system: makeFireworkSystem())
        }
        
        fireworkTask = Task {
            try? await Task.sleep(for: .seconds(2.0))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.25)) {
                    fireworkBursts.removeAll()
                }
            }
        }
    }
    
    private func makeFireworkSystem() -> VortexSystem {
        let x = Double.random(in: 0.1...0.9)
        let y = 1.0

        let system = VortexSystem.fireworks.makeUniqueCopy()
        system.position = [x, y]
        system.emissionLimit = 1
        system.birthRate = 20
        return system
    }
}

private struct FireworkBurst: Identifiable {
    let id = UUID()
    let system: VortexSystem
}

#Preview {
    NavigationStack {
        DebugSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
