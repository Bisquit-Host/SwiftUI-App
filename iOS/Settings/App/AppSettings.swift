import SwiftUI

struct AppSettings: View {
    var body: some View {
        ScrollView {
#if !os(visionOS)
            AppIconSettings()
#endif
            CacheSettings()
            OtherAppSettings()
        }
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
