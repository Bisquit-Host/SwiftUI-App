import SwiftUI

struct ConsoleMessage: View {
    private let message: AttributedString
    
    init(_ message: AttributedString) {
        self.message = message
    }
    
    var body: some View {
        Text(message)
            .fontSize(10)
            .monospaced()
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    ConsoleMessage("Preview")
}
