import SwiftUI
import Calagopus

struct LogMetaParent: View {
    private let properties: [String: CalagopusLogValue]
    
    init(_ properties: [String: CalagopusLogValue]) {
        self.properties = properties
    }
    
    var body: some View {
#if os(watchOS) && os(macOS)
        LogMetaView(properties)
#else
        NavigationStack {
            LogMetaView(properties)
        }
#endif
    }
}

#Preview {
    LogMetaParent([:])
        .darkSchemePreferred()
}
