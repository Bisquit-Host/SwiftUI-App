import SwiftUI
import PteroNet

struct LogSectionList: View {
    private let logs: [LogAttributes]
    
    init(_ logs: [LogAttributes]) {
        self.logs = logs
    }
    
    var body: some View {
        List {
            ForEach(logs) {
                LogSectionCard($0)
                    .listRowSeparatorTint(.white.opacity(0.1))
            }
        }
        .frame(height: 300)
        .listStyle(.plain)                 // removes grouped insets
        .scrollContentBackground(.hidden) // hides default system background
        .background(Color.clear)         // transparent background
    }
}

#Preview {
    LogSectionList([PreviewProp.logAttributes])
        .darkSchemePreferred()
}
