import SwiftUI

private struct PanelUsesSharedNavigationTitleKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var panelUsesSharedNavigationTitle: Bool {
        get { self[PanelUsesSharedNavigationTitleKey.self] }
        set { self[PanelUsesSharedNavigationTitleKey.self] = newValue }
    }
}
