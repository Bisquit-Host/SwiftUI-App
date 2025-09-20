import SwiftUI
import PteroNet

struct LogMetaParent: View {
    private let properties: [String: CodableValue]
    
    init(_ properties: [String: CodableValue]) {
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
}
