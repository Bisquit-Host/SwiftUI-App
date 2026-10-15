import SwiftUI

struct DatabaseTab: View {
    @Environment(DatabaseVM.self) private var vm
    
    var body: some View {
        List {
            DatabaseList()
        }
        .navigationTitle("Databases")
        .refreshableTask {
            await vm.fetchInstances()
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseTab()
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
