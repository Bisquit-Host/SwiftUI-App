import SwiftUI

struct VDSProtectionAttacksSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    var body: some View {
        ServiceSectionCard(vm.attacks.isEmpty ? nil : "Recent attacks") {
            if vm.isLoading && vm.attacks.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                
            } else if vm.attacks.isEmpty {
                ContentUnavailableView("No attacks recorded", systemImage: "shield.lefthalf.filled.badge.checkmark")
                    .frame(height: 160)
                
            } else {
                ForEach(vm.attacks.prefix(5)) {
                    VDSProtectionAttackCard($0)
                }
            }
        } primaryButton: {
            NavigationLink {
                VDSProtectionAttacksView()
                    .environment(vm)
            } label: {
                Text("View all")
            }
            .buttonStyle(.bordered)
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
