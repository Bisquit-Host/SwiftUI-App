import SwiftUI

struct UserListParent: View {
    var body: some View {
#if os(watchOS)
        UserList()
#else
        NavigationView {
            UserList()
        }
#endif
    }
}

#Preview {
    UserListParent()
}
