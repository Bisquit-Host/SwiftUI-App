import SwiftUI

struct BrowserListMCRU: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.mcPlans) {
            BrowserCardMC($0)
        }
    }
}

#Preview {
    BrowserListMCRU()
        .environment(BrowserVM())
}
