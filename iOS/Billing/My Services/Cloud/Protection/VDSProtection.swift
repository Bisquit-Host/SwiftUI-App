import SwiftUI

struct VDSProtection: View {
    @State private var vm = VDSProtectionVM()
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VDSProtectionIPSection()
                ProtectionProfilesSection()
                VDSProtectionAttacksSection()
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
    VDSProtection(1)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}

