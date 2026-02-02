import ScrechKit

struct LogCardTimestamp: View {
    private let timestamp: Date
    
    init(_ timestamp: Date) {
        self.timestamp = timestamp
    }
    
    var body: some View {
        TimelineView(.everyMinute) { _ in
            Text(timeSinceISO(timestamp))
                .monospacedDigit()
                .secondary()
#if !os(macOS)
                .footnote()
#endif
        }
    }
}

#Preview {
    LogCardTimestamp(PreviewProp.logAttributes.timestamp)
        .darkSchemePreferred()
}
