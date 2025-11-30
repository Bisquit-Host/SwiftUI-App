import SwiftUI
import WidgetKit

struct PowerWidget: Widget {
    private let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: ResourcesTimelineProvider()) {
            PowerWidgetView($0)
                .containerBackground(.ultraThinMaterial, for: .widget)
        }
        .configurationDisplayName("Change Power")
        .description("Send power signals to your server")
        .contentMarginsDisabled()
        .supportedFamilies([
            .systemSmall
        ])
    }
}

#Preview(as: .systemSmall) {
    PowerWidget()
} timeline: {
    ResourcesUsageEntry(date: .now, name: "Preview Server", id: "bf7903cc", state: "running")
}
