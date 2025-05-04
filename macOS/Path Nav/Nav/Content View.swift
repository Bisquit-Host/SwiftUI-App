import SwiftUI

struct ContentView: View {
    @Environment(NavModel.self) private var nav
    private var vm = ServerListVM()
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: ValueStore
    
#if os(macOS)
    @Environment(\.appearsActive) private var appearsActive
#endif
    
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
#warning("macOS 15")
        }
        //        .windowFullScreenBehavior(.disabled)
        .environment(nav)
        .environment(vm)
        .backgroundBlur()
        .sheet($nav.showNavModePicker) {
            NavModePicker($store.navMode)
        }
        .onFirstAppear {
            vm.loadServers()
            
            if !System.lowPowerMode {
                await vm.checkForUpdates()
            }
        }
        .task {
            vm.fetchServers(false)
            try? nav.load()
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            if newScenePhase == .background {
                try? nav.save()
            }
        }
        .onChange(of: nav.selectedTab) {
            try? nav.save()
        }
        .onChange(of: nav.path) {
            try? nav.save()
        }
        .onChange(of: nav.selectedServer) {
            try? nav.save()
        }
#if os(macOS)
        .onChange(of: appearsActive) { _, appearsActive in
            if !appearsActive {
                try? nav.save()
            }
        }
#endif
    }
}

#Preview {
    ContentView()
        .environment(NavModel())
}
