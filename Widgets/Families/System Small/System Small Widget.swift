import SwiftUI
import WidgetKit

struct SystemSmallWidget: Widget {
    private let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            SystemSmallWidgetView(entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([
            .systemSmall
        ])
        //                .onBackgroundURLSessionEvents(matching: "") { identifier, completion in
        //
        //                }
    }
}

#Preview(as: .systemSmall) {
    SystemSmallWidget()
} timeline: {
    SystemSmallEntry(
        date: .now,
        cpuUsage: 0,
        ramUsage: 0
    )
    
    SystemSmallEntry(
        date: .now,
        cpuUsage: 0,
        ramUsage: 0
    )
}
