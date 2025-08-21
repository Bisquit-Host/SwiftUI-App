import SwiftUI

struct UserListParent: View {
    var body: some View {
#if os(watchOS)
        UserList()
#else
        NavigationStack {
            UserList()
        }
        .presentationDragIndicator(.hidden)
#endif
    }
}

#Preview {
    UserListParent()
}
