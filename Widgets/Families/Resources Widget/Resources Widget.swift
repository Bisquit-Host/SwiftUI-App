import SwiftUI
import WidgetKit

struct ResourcesWidget: Widget {
    private let kind = "Widgets test"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: CryptoPriceConfigurationIntent.self,
            provider: CryptoPriceTimelineProvider()
        ) { entry in
            ResourcesWidgetView(entry)
        }
        .configurationDisplayName("Server Info")
        // .description("")
        .supportedFamilies([
            .systemMedium
        ])
    }
}

#Preview(as: .systemSmall) {
    ResourcesWidget()
} timeline: {
    ResourcesUsageEntry(
        date: Date(),
        name: "Preview Server",
        id: "previewid",
        state: "running"
    )
}
