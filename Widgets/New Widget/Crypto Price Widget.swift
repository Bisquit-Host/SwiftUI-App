import SwiftUI
import WidgetKit

struct CryptoPriceEntry: TimelineEntry {
    let date: Date
    let name: String
    let id: String
    let state: String
}

struct CryptoPriceWidgetView: View {
    private let entry: CryptoPriceEntry
    
    init(_ entry: CryptoPriceEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            Text(entry.name)
                .title(.bold)
            
            Text(entry.state)
                .caption2()
                .padding(.bottom, 8)
            
            Text(entry.date, format: .dateTime.minute().second())
                .footnote()
            
            Button("Update", intent: RefreshIntent())
        }
        .containerBackground(for: .widget) {}
    }
}

struct CryptoPriceTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CryptoPriceEntry {
        .init(
            date: Date(),
            name: "Bitcoin",
            id: "123",
            state: "BTC"
        )
    }
    
    func getSnapshot(
        for configuration: CryptoPriceConfigurationIntent,
        in context: Context,
        completion: @escaping (CryptoPriceEntry) -> ()
    ) {
        let entry = CryptoPriceEntry(
            date: Date(),
            name: "Bitcoin",
            id: "123",
            state: "BTC"
        )
        
        completion(entry)
    }
    
    func getTimeline(
        for configuration: CryptoPriceConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<CryptoPriceEntry>) -> ()
    ) {
        // Extract required info from configuration
        
        guard
            let assetId = configuration.selectedCrypto?.identifier,
            let name = configuration.selectedCrypto?.name,
            let id = configuration.selectedCrypto?.id
        else {
            showEmptyState(completion, error: "1")
            return
        }
        
        Task {
            // Fetch asset details
            let assetDetails = await AssetFetcher.fetchAssetDetails(assetId)
            
            // Create `CryptoPriceEntry` using based on user selected configuration & fetched info
            let entry = CryptoPriceEntry(
                date: Date(),
                name: name,
                id: id,
                state: assetDetails.priceUsd
            )
            
            // Trigger completion & next fetch in 15 mins
            executeTimelineCompletion(completion, timelineEntry: entry)
        }
    }
    
    private func showEmptyState(
        _ completion: @escaping (Timeline<CryptoPriceEntry>) -> (),
        error: String
    ) {
        let entry = CryptoPriceEntry(
            date: Date(),
            name: "",
            id: "",
            state: error
        )
        
        // Trigger completion & next fetch in 15 mins
        executeTimelineCompletion(completion, timelineEntry: entry)
    }
    
    func executeTimelineCompletion(
        _ completion: @escaping (Timeline<CryptoPriceEntry>) -> (),
        timelineEntry: CryptoPriceEntry
    ) {
        // Next fetch in 15 mins
        let nextUpdate = Calendar.current.date(
            byAdding: DateComponents(minute: 15),
            to: Date()
        )!
        
        let timeline = Timeline(
            entries: [timelineEntry],
            policy: .after(nextUpdate)
        )
        
        completion(timeline)
    }
}

struct CryptoPriceWidget: Widget {
    let kind = "Widgets test"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: CryptoPriceConfigurationIntent.self,
            provider: CryptoPriceTimelineProvider()
        ) { entry in
            CryptoPriceWidgetView(entry)
        }
        .configurationDisplayName("Crypto Price Widget")
        .description("Get price for your selected asset")
        .supportedFamilies([
            .systemMedium
        ])
    }
}

#Preview(as: .systemSmall) {
    CryptoPriceWidget()
} timeline: {
    CryptoPriceEntry(
        date: Date(),
        name: "Bitcoin",
        id: "preview",
        state: "BTC"
    )
}
