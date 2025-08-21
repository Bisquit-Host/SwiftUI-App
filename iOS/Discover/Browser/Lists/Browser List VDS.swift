import SwiftUI

struct BrowserListVds: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.vdsPlans) { plan in
            BrowserCardVds(plan)
        }
    }
}

#Preview {
    BrowserListVds()
        .darkSchemePreferred()
        .environment(BrowserVM())
}
