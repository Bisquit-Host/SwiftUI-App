import SwiftUI

extension View {
    @ViewBuilder
    func serverListSearch(_ text: Binding<String>, isActive: Bool) -> some View {
        if isActive {
            self.searchable(text: text)
        } else {
            self
        }
    }
}
