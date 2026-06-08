import SwiftUI

struct BigGlassyIcon: View {
    private let icon: String
    private let tint: Color
    
    init(_ icon: String, tint: Color) {
        self.icon = icon
        self.tint = tint
    }
    
    var body: some View {
        Image(systemName: icon)
            .foregroundStyle(tint)
            .fontSize(20)
            .frame(45)
            .background(tint.opacity(0.25), in: .rect(cornerRadius: 16))
    }
}

//#Preview {
//    BigGlassyIcon()
//}
