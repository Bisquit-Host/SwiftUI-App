import SwiftUI

struct SubuserListParent: View {
    var body: some View {
#if os(watchOS)
        SubuserList()
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
