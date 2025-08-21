import SwiftUI

struct BrowserListMCRU: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.mcPlans) { plan in
            BrowserCardMC(plan)
        }
    }
}

#Preview {
    BrowserListMCRU()
        .environment(BrowserVM())
}
