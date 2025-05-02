import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    private var nav: NavModel = .shared
    private var dataModel: DataModel = .shared
    
#if os(macOS)
    @Environment(\.appearsActive) private var appearsActive
#endif
    
    @AppStorage("experience") private var experience: Experience?
    
    var body: some View {
        @Bindable var nav = nav
        
        Group {
            switch experience {
            case .stack?:
                StackContentView()
                
            case .twoColumn?:
                TwoColumnContentView()
                
            case .threeColumn?:
                ThreeColumnContentView()
                
            case nil:
                VStack {
                    Text("🧑🏼‍🍳 Bon appétit!")
                        .largeTitle()
                    
                    ExperienceButton()
                }
                .padding()
                .onAppear {
                    nav.showExperiencePicker = true
                }
            }
        }
        .environment(nav)
        .environment(dataModel)
        .sheet(isPresented: $nav.showExperiencePicker) {
            ExperiencePicker($experience)
        }
        .task {
            try? nav.load()
            dataModel.fetchServers(false)
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
}
