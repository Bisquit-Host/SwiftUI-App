import SwiftUI

struct VDSProtectionAttacksSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    var body: some View {
        VDSSectionCard(vm.attacks.isEmpty ? nil : "Recent attacks") {
            if vm.isLoading && vm.attacks.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                
            } else if vm.attacks.isEmpty {
                ContentUnavailableView("No attacks recorded", systemImage: "shield.lefthalf.filled.badge.checkmark")
                    .frame(height: 160)
                
            } else {
                ForEach(vm.attacks) {
                    VDSProtectionAttackCard($0)
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
        .animation(.default, value: vm.attacks)
    }
}

#Preview {
    VDSProtectionAttacksSection()
        .environment(VDSProtectionVM())
        .padding()
        .darkSchemePreferred()
}

