import SwiftUI
import Calagopus

struct LogCardEvent: View {
    let log: LogAttributes // not private
    
    init(_ log: LogAttributes) {
        self.log = log
    }
    
    var body: some View {
        Text(eventDescription)
#if os(macOS)
            .monospaced()
#else
            .footnote(design: .monospaced)
#endif
    }
}

#Preview {
    LogCardEvent(PreviewProp.logAttributes)
        .darkSchemePreferred()
}
