import SwiftUI
import WidgetKit

struct PowerWidget: Widget {
    private let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: CryptoPriceConfigurationIntent.self, provider: ResourcesTimelineProvider()) {
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
    PowerEntry(
        date: .now,
        configuration: .init(
            id: .init(title: "", description: "", default: "1123")
        )
    )
}
