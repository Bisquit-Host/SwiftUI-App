import SwiftUI

struct VDSProtectionAttacksView: View {
    @Environment(VDSProtectionVM.self) private var vm

    var body: some View {
        List {
            ForEach(vm.attacks) {
                VDSProtectionAttackRowView($0)
            }

            if vm.canLoadMoreAttacks {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .task(id: vm.attacks.count) {
                        await vm.loadMoreAttacks()
                    }
            }
        }
        .scrollContentBackground(.visible)
        .navigationTitle("Recent attacks")
    }
}
