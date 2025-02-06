import SwiftUI
import WidgetKit

struct SomeNewWidget: Widget {
    private let kind = "Widgets test"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: CryptoPriceConfigurationIntent.self,
            provider: CryptoPriceTimelineProvider()
        ) { entry in
            CryptoPriceWidgetView(entry)
        }
        .configurationDisplayName("Server Info")
        // .description("")
        .supportedFamilies([
            .systemMedium
        ])
    }
}

#Preview(as: .systemSmall) {
    SomeNewWidget()
} timeline: {
    ResourcesUsageEntry(
        date: Date(),
        name: "Preview Server",
        id: "previewid",
        state: "running"
    )
}
