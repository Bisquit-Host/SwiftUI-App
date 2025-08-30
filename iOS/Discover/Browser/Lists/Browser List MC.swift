import SwiftUI

struct BrowserListMC: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.mcPlans) {
            BrowserCardMC($0)
        }
    }
}

#Preview {
    BrowserListMC()
        .environment(BrowserVM())
}
