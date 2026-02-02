import SwiftUI

struct UpgradeNoticeView: View {
    let message: LocalizedStringKey
    let tint: Color
    
    init(_ message: LocalizedStringKey, tint: Color = .orange) {
        self.message = message
        self.tint = tint
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(tint)
            
            Text(message)
                .footnote()
                .secondary()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        }
    }
}
