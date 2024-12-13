import SwiftUI
import PteroNet

struct LogViewParent: View {
    private let properties: [String: CodableValue]
    
    init(_ properties: [String: CodableValue]) {
        self.properties = properties
    }
    
    var body: some View {
#if os(watchOS) && os(macOS)
        LogDetailView(properties)
#else
        NavigationView {
            LogDetailView(properties)
        }
#endif
    }
}

#Preview {
    LogViewParent(sampleJSON(.logAttributes))
}
