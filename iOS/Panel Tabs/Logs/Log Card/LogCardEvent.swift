import SwiftUI
import PteroNet

struct LogCardEvent: View {
    let log: LogAttributes
    
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

//#Preview {
//    LogCardEvent()
//}
