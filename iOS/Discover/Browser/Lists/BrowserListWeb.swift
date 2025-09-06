import SwiftUI

struct BrowserListWeb: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        ForEach(vm.webPlans) {
            BrowserCardWeb($0)
        }
    }
}

#Preview {
    BrowserListWeb()
        .environment(BrowserVM())
}
