import SwiftUI

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            Button("VIEW ONLY", role: .destructive) {}
            
            ForEach(vm.startupVariables, id: \.name) { variable in
                StartupCard(variable)
            }
        }
        .navigationTitle("Startup")
        .task {
            vm.fetchStartupVariables()
        }
    }
}

#Preview {
    StartupList()
}
