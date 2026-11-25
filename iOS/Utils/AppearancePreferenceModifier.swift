import SwiftUI
#if canImport(Appearance)
import Appearance

/// Sheets keep their own color scheme and sometimes miss appearance changes, so the presenter's scheme is passed in explicitly
struct AppearancePreferenceModifier: ViewModifier {
    @Environment(\.colorScheme) private var inheritedColorScheme
    @EnvironmentObject private var store: ValueStore

    var presentingColorScheme: ColorScheme?

    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, store.appearance.scheme ?? presentingColorScheme ?? inheritedColorScheme)
            .preferredColorScheme(store.appearance.scheme ?? presentingColorScheme)
    }
}
#endif
