import SwiftUI

struct BrowserListWeb: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.webPlans) { plan in
            BrowserCardWeb(plan)
        }
    }
}

#Preview {
    BrowserListWeb()
        .darkSchemePreferred()
        .environment(BrowserVM())
}
