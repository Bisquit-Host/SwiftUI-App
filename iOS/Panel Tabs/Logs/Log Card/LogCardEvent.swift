import SwiftUI
import Calagopus

struct LogCardEvent: View {
    let log: CalagopusServerLog // not private
    
    init(_ log: CalagopusServerLog) {
        self.log = log
    }
    
    var body: some View {
        Text(eventDescription)
            .footnote(design: .monospaced)
    }
}

#Preview {
    LogCardEvent(PreviewProp.logAttributes)
        .darkSchemePreferred()
}
