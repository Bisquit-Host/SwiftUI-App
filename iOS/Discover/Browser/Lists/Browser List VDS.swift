import SwiftUI

struct BrowserListVds: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.vdsPlans) {
            BrowserCardVds($0)
        }
    }
}

#Preview {
    BrowserListVds()
        .environment(BrowserVM())
}
