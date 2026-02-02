import SwiftUI

struct PasskeyCardTransportTag: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.horizontal.fill")
                .caption2()
            
            Text(text)
                .caption()
        }
        .secondary()
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.primary.opacity(0.04), in: .capsule)
        .overlay {
            Capsule()
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
    }
}

#Preview {
    PasskeyCardTransportTag("Preview")
        .darkSchemePreferred()
}
