import SwiftUI

struct VDSProtection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    private let serviceID: Int
    
    init(_ serviceID: Int) {
        self.serviceID = serviceID
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VDSProtectionIPSection()
                VDSProtectionAttacksSection()
                ProtectionProfilesSection()
            }
            .scenePadding()
        }
        .task {
            await vm.loadIfNeeded(serviceID)
        }
        .refreshable {
            await vm.load(serviceID)
        }
    }
}

#Preview {
    VDSProtection(1)
        .environment(VDSProtectionVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
