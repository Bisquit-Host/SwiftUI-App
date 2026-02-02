import SwiftUI

struct VDSSheetSSHLogs: View {
    @Binding private var logs: [String]
    
    init(_ logs: Binding<[String]>) {
        _logs = logs
    }
    
    var body: some View {
        ScrollView {
            ForEach(logs, id: \.self) {
                Text($0)
                    .footnote()
                    .monospaced()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Logs")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
    }
}
