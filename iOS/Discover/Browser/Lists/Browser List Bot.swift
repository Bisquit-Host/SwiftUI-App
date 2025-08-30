import SwiftUI

struct BrowserListBot: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.botPlans) {
            BrowserCardBot($0)
        }
    }
}

#Preview {
    BrowserListBot()
        .environment(BrowserVM())
}
