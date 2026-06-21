import SwiftUI

struct SubuserListParent: View {
    var body: some View {
#if os(watchOS)
        UserList()
#else
        NavigationStack {
            SubuserList()
        }
        .presentationDragIndicator(.hidden)
#endif
    }
}

#Preview {
    SubuserListParent()
        .darkSchemePreferred()
}
