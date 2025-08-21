import SwiftUI

struct BrowserListBot: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.botPlans) { plan in
            BrowserCardBot(plan)
        }
    }
}

#Preview {
    BrowserListBot()
        .environment(BrowserVM())
}
