import SwiftUI

struct CloudProtectionAttacksSection: View {
    @Environment(CloudProtectionVM.self) private var vm
    
    var body: some View {
        BillingSectionCard("Recent attacks") {
            VStack(alignment: .leading, spacing: 10) {
                if vm.isLoading && vm.attacks.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    
                } else if vm.attacks.isEmpty {
                    Text("No attacks recorded")
                        .footnote()
                        .secondary()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(vm.attacks) { attack in
                            CloudProtectionAttackRow(attack: attack)
                        }
                    }
                }
                
                if vm.canLoadMoreAttacks {
                    Button(vm.isLoadingAttacks ? "Loading..." : "Load more") {
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
    }
}

#Preview {
    CloudProtectionAttacksSection()
        .environment(CloudProtectionVM())
        .padding()
        .darkSchemePreferred()
}

