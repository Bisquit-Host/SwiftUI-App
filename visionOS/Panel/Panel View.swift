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
    @AppStorage("show_power_buttons") private var showPowerButtons = true
    @AppStorage("show_info") private var showInfo = true
    
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
            } else {
                Text("Panel")
            }
        }
        .task {
            vm.fetchServerDetails()
        }
        .toolbar {
            Menu {
                Button {
                    withAnimation {
                        showPowerButtons.toggle()
                    }
                } label: {
                    Text("Show power buttons")
                }
                
                Button {
                    withAnimation {
                        showInfo.toggle()
                    }
                } label: {
                    Text("Show power buttons")
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        .ornament(attachmentAnchor: .scene(.trailing)) {
            if showInfo {
                if let server = vm.server {
                    PanelOrnamentInfo(server)
                }
            }
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            if showPowerButtons {
                HStack {
                    Button {
                        
                    } label: {
                        Label("Start", systemImage: "play")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Stop", systemImage: "stop")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Restart", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Capsule()
                        .frame(width: 4, height: 32)
                    
                    Menu {
                        Button {
                            
                        } label: {
                            Label("Kill", systemImage: "power")
                        }
                    } label: {
                        Label("Kill", systemImage: "power")
                    }
                }
                .padding(.bottom, 90)
            }
        }
    }
}

#Preview {
    NavigationView {
        PanelView("")
    }
    .navigationViewStyle(.stack)
}
