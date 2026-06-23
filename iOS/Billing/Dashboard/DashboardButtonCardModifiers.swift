import SwiftUI

private let dashboardButtonCardCornerRadius = 12.0

extension View {
    func dashboardButtonHoverShape() -> some View {
        roundedHoverEffect(cornerRadius: dashboardButtonCardCornerRadius)
    }
    
    func dashboardButtonCardBackground() -> some View {
        dashboardButtonHoverShape()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: dashboardButtonCardCornerRadius))
    }
}
