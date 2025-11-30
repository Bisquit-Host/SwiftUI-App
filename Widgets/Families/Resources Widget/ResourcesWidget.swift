import SwiftUI
import WidgetKit

struct ResourcesWidget: Widget {
    private let kind = "Widgets test"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: ResourcesTimelineProvider()) {
            ResourcesWidgetView($0)
        }
        .configurationDisplayName("Server Info")
        .description("View resource usage of your servers")
        .supportedFamilies([
            .systemMedium
        ])
    }
}

#Preview(as: .systemSmall) {
    ResourcesWidget()
} timeline: {
    ResourcesUsageEntry(date: Date(), name: "Preview Server", id: "previewid", state: "running")
}
