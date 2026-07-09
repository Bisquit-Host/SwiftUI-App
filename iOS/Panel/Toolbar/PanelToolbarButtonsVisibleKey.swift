import SwiftUI

private struct PanelToolbarButtonsVisibleKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var panelToolbarButtonsVisible: Bool {
        get { self[PanelToolbarButtonsVisibleKey.self] }
        set { self[PanelToolbarButtonsVisibleKey.self] = newValue }
    }
}
