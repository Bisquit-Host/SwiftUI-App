import SwiftUI

struct VDSProtectionAttacksSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    var body: some View {
        VDSSectionCard(vm.attacks.isEmpty ? nil : "Recent attacks") {
            VStack(alignment: .leading, spacing: 10) {
                if vm.isLoading && vm.attacks.isEmpty {
                    ProgressView()
                    
                } else if vm.attacks.isEmpty {
                    ContentUnavailableView("No attacks recorded", systemImage: "shield.lefthalf.filled.badge.checkmark")
                    
                } else {
                    ForEach(vm.attacks) {
                        VDSProtectionAttackCard(attack: $0)
                    }
                    
                    if vm.canLoadMoreAttacks {
                        Button("Load more") {
                            Task {
                                await vm.loadMoreAttacks()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .disabled(vm.isLoadingAttacks || vm.isPerformingAction)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.default, value: vm.attacks)
        }
    }
}

#Preview {
    VDSProtectionAttacksSection()
        .environment(VDSProtectionVM())
        .padding()
        .darkSchemePreferred()
}

