import SwiftUI

struct PanelView: View {
    private var vm: PanelVM
    
    private let id: String
    
    init(_ id: String,
         model: PanelVM = PanelVM("")
    ) {
        self.id = id
        self.vm = PanelVM(id)
    }
    
    @AppStorage("tab_panel") private var tabPanel: Tab = .info
    
    var body: some View {
        TabView(selection: $tabPanel) {
            if let server = vm.server {
                InfoTab(server)
                    .tag(Tab.info)
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                
                Console()
                    .tag(Tab.console)
                    .tabItem {
                        Label("Console", systemImage: "apple.terminal")
                    }
            }
        }
    }
}

#Preview {
    PanelView("")
}
