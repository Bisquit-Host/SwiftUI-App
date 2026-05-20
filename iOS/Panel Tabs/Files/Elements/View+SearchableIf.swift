import SwiftUI

extension View {
    @ViewBuilder
    func searchableIf(_ isEnabled: Bool, text: Binding<String>) -> some View {
        if isEnabled {
            searchable(text: text)
        } else {
            self
        }
    }
}
