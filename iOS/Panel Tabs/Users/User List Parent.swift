import SwiftUI

struct UserListParent: View {
    var body: some View {
#if os(watchOS)
        UserList()
#else
        NavigationView {
            UserList()
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large])
#endif
    }
}

#Preview {
    UserListParent()
}
