import SwiftUI
import WidgetKit

struct AccessoryCircularWindget: Widget {
    let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StaticProvider()
        ) { _ in
            AccessoryCircularView()
                .containerBackground(.ultraThinMaterial, for: .widget)
        }
        .supportedFamilies([.accessoryCircular])
    }
}

struct AccessoryCircularView: View {
    var body: some View {
        Image(systemName: "externaldrive.connected.to.line.below")
            .largeTitle()
    }
}

#Preview(as: .accessoryCircular) {
    AccessoryCircularWindget()
} timeline: {
    StaticEntry(date: Date())
}
