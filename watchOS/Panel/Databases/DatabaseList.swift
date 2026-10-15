import SwiftUI

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    var body: some View {
        if vm.instances.isEmpty {
            ContentUnavailableView(
                "No managed databases",
                systemImage: "externaldrive.badge.icloud"
            )
        } else {
            ForEach(vm.instances) {
                DatabaseCard($0)
            }
        }
    }
}

#Preview {
    List {
        DatabaseList()
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
