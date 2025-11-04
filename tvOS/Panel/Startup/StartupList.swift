import SwiftUI

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.startupVariables) {
                StartupCard($0)
            }
        }
        .navigationTitle("Startup (view only)")
        .task {
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
