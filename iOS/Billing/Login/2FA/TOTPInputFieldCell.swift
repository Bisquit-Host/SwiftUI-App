import SwiftUI

struct TOTPInputFieldCell: View {
    let digit: String
    let isActive: Bool
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Text(digit)
            .title2()
            .monospacedDigit()
            .frame(width: width, height: height)
            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.primary.opacity(0.35) : .primary.opacity(0.08), lineWidth: isActive ? 1.5 : 1)
            }
    }
}
