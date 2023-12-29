import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var showRawCommand = false
    
    var body: some View {
        @Bindable var binding = vm
        
        List {
            Section("Startup Command") {
                Text(showRawCommand ? vm.rawStartupCommand : vm.startupCommand)
                    .footnote(design: .monospaced)
                
                Toggle("Raw", isOn: $showRawCommand)
            }
            
            ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                Text("\(key): \(value)")
            }
            
            ForEach(vm.startupVariables, id: \.name) { variable in
                StartupCard(server,
                            variable: variable)
            }
        }
        .navigationTitle("Startup")
        .scrollIndicators(.never)
        .task {
            vm.fetchStartupVariables()
        }
    }
}

#Preview {
    StartupView(
        sampleJSON(.serverListAttributes)
    )
    .environment(ServerSettingsVM(""))
}
