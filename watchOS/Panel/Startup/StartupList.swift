import SwiftUI

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            Section("Startup Command") {
                Text(vm.startupCommand)
                    .font(.caption.monospaced())
            }
            
            ForEach(vm.startupVariables) {
                StartupCard($0)
            }
        }
        .navigationTitle("Startup")
        .task {
            await vm.fetchStartupVariables()
        }
        .refreshable {
            await vm.fetchStartupVariables()
        }
    }
}

#Preview {
    NavigationStack {
        StartupList()
    }
    .darkSchemePreferred()
    .environment(StartupVM(""))
}
