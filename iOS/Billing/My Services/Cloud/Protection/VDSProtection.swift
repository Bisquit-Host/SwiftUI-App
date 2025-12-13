import SwiftUI

struct VDSProtection: View {
    @State private var vm = VDSProtectionVM()
    let serviceId: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VDSProtectionIPSection()
                VDSProtectionProfilesSection()
                CloudProtectionAttacksSection()
            }
            .scenePadding()
        }
        .environment(vm)
        .refreshableTask {
            await vm.load(serviceId)
        }
    }
}

#Preview {
    VDSProtection(serviceId: 1)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}

