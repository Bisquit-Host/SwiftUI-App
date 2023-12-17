import SwiftUI

struct SettingsParent: View {
    var body: some View {
#if os(watchOS)
        Settings()
#else
        NavigationView {
            Settings()
        }
#endif
    }
}

#Preview {
    SettingsParent()
}
