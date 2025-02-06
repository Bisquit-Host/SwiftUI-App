import SwiftUI
import WidgetKit

struct PowerWidget: Widget {
    private let kind = "Widgets"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: PowerProvider()
        ) { entry in
            VStack {
                let id = entry.configuration.serverId
                
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
            .containerBackground(.fill.tertiary, for: .widget)
        }
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
            serverId: .init(title: "", description: "", default: "1123")
        )
    )
}
