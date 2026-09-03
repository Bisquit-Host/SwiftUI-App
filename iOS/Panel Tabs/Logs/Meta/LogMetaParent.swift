import SwiftUI
import Calagopus

struct LogMetaParent: View {
    private let properties: [String: CalagopusLogValue]
    
    init(_ properties: [String: CalagopusLogValue]) {
        self.properties = properties
    }
    
    var body: some View {
        NavigationStack {
            LogMetaView(properties)
        }
    }
}

#Preview {
    LogMetaParent([:])
        .darkSchemePreferred()
}
