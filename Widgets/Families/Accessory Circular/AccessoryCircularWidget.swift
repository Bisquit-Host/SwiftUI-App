import SwiftUI
import WidgetKit

struct AccessoryCircularWidget: Widget {
    private let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StaticProvider()) { _ in
            AccessoryCircularView()
                .containerBackground(.ultraThinMaterial, for: .widget)
        }
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    AccessoryCircularWidget()
} timeline: {
    StaticEntry(date: Date())
}
