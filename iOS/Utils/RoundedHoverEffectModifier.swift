import SwiftUI

extension View {
    func roundedHoverEffect(cornerRadius: CGFloat = 12) -> some View {
        contentShape(.rect(cornerRadius: cornerRadius))
            .contentShape(.hoverEffect, .rect(cornerRadius: cornerRadius))
            .containerShape(.rect(cornerRadius: cornerRadius))
            .buttonBorderShape(.roundedRectangle(radius: cornerRadius))
            .hoverEffect(.highlight)
    }
}
