import ScrechKit

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            Section("Startup Command") {
                Text(vm.startupCommand)
                    .caption(design: .monospaced)
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
