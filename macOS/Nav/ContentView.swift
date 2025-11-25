import SwiftUI

struct ContentView: View {
    private var vm = ServerListVM()
    @Environment(NavModel.self) private var nav
    @EnvironmentObject private var store: ValueStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        @Bindable var nav = nav
        
        Group {
            switch store.navMode {
            case .stack?:
                StackContentView()
                
            case .twoColumn?:
                TwoColumnContentView()
                
            case .threeColumn?:
                ThreeColumnContentView()
                
            case nil:
                NavModeButton()
                    .padding()
                    .onAppear {
                        nav.showNavModePicker = true
                    }
            }
        }
        .environment(nav)
        .environment(vm)
        .backgroundBlur()
        .sheet($nav.showNavModePicker) {
            NavModePicker($store.navMode)
        }
        .onFirstAppear {
            vm.loadServers()
        }
        .task {
            try? nav.load()
            await vm.fetchServers(store.adminServerList)
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            if newScenePhase == .background {
                save()
            }
        }
        .onChange(of: nav.selectedTab) {
            save()
        }
        .onChange(of: nav.path) {
            save()
        }
        .onChange(of: nav.selectedServers) {
            save()
        }
        .onChange(of: appearsActive) { _, appearsActive in
            if !appearsActive {
                save()
            }
        }
        .onGamepadPressed(.menu, cooldown: 1) {
            openSettings()
        }
    }
    
    private func save() {
        try? nav.save()
    }
}

#Preview {
    ContentView()
        .darkSchemePreferred()
        .environment(NavModel())
        .environmentObject(ValueStore())
}
