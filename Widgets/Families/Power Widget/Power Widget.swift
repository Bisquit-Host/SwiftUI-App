import SwiftUI
import WidgetKit

struct PowerWidget: Widget {
    private let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: CryptoPriceConfigurationIntent.self,
            provider: ResourcesTimelineProvider()
        ) { entry in
            VStack {
                let id = entry.id
                
                if id.isEmpty || id.count != 8 {
                    Text("Configure first")
                } else {
                    Text(id)
                    
                    HStack {
                        Button(intent: StartServerIntent(id)) {
                            Text("Start")
                        }
                        
                        Button(role: .destructive, intent: StopServerIntent(id)) {
                            Text("Stop")
                        }
                    }
                    
                    Button(intent: RestartServerIntent(id)) {
                        Text("Restart")
                    }
                }
            }
            .containerBackground(for: .widget) {}
        }
        .configurationDisplayName("Change Power")
        .description("Send power signals to your server")
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
