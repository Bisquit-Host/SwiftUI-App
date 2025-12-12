import SwiftUI

struct CloudProtection: View {
    @State private var vm = CloudProtectionVM()
    let serviceId: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CloudProtectionIPSection()
                CloudProtectionProfilesSection()
                CloudProtectionAttacksSection()
            }
            .scenePadding()
        }
        .navigationTitle("Cloud Protection")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .environment(vm)
        .refreshableTask {
            await vm.load(serviceId)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
}

#Preview {
    CloudProtection(serviceId: 1)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}

