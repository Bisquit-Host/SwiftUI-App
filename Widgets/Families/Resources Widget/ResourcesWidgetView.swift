import ScrechKit
import WidgetKit
import Calagopus

struct ResourcesWidgetView: View {
    private let entry: ResourcesUsageEntry
    
    init(_ entry: ResourcesUsageEntry) {
        self.entry = entry
    }
    
    var body: some View {
        Group {
            if entry.id.isEmpty {
                ConfigureWidgetView("Bisquit.Host", image: Image(.defaultIcon), lastStep: "3. **Choose a server** from the list")
            } else {
                ResourcesConfiguredWidgetView(entry)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

#Preview(as: .systemMedium) {
    ResourcesWidget()
} timeline: {
    ResourcesUsageEntry(
        date: .now,
        name: "Preview",
        id: "bf7903cc",
        state: "Running"
    )
}
