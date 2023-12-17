import SwiftUI

struct AccountParent: View {
    var body: some View {
#if os(watchOS)
        AccountView()
#else
        NavigationView {
            AccountView()
        }
#endif
    }
}

#Preview {
    AccountParent()
}
