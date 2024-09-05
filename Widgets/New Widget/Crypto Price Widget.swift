import SwiftUI
import WidgetKit

struct CryptoPriceEntry: TimelineEntry {
    let date: Date
    let name: String
    let symbol: String
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
            
            Text(entry.symbol)
                .footnote()
                .padding(.bottom, 8)
        }
        .containerBackground(for: .widget) {}
    }
}

struct CryptoPriceTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CryptoPriceEntry {
        .init(
            date: Date(),
            name: "Bitcoin",
            symbol: "BTC"
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
            symbol: "BTC"
        )
        
        completion(entry)
    }
    
    func getTimeline(
        for configuration: CryptoPriceConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<CryptoPriceEntry>) -> ()
    ) {
        // Extract required info from `configuration`
        
        guard
            let assetId = configuration.selectedCrypto?.identifier,
            let name = configuration.selectedCrypto?.name,
            let symbol = configuration.selectedCrypto?.id else {
            
            showEmptyState(completion: completion)
            return
        }
        
        Task {
            // Fetch asset details
            guard let assetDetails = try? await AssetFetcher.fetchAssetDetails(assetId) else {
                showEmptyState(completion: completion)
                return
            }
            
            // Create `CryptoPriceEntry` using based on user selected configuration & fetched info
            let entry = CryptoPriceEntry(
                date: Date(),
                name: name,
                symbol: symbol
            )
            
            // Trigger completion & next fetch happens in 15 mins
            executeTimelineCompletion(completion, timelineEntry: entry)
        }
    }
    
    private func showEmptyState(completion: @escaping (Timeline<CryptoPriceEntry>) -> ()) {
        
        let entry = CryptoPriceEntry(
            date: Date(),
            name: "",
            symbol: "Please select an asset"
        )
        
        // Trigger completion & next fetch happens in 15 mins
        executeTimelineCompletion(completion, timelineEntry: entry)
    }
    
    func executeTimelineCompletion(
        _ completion: @escaping (Timeline<CryptoPriceEntry>) -> (),
        timelineEntry: CryptoPriceEntry
    ) {
        // Next fetch happens in 15 mins
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
            .systemSmall,
        ])
    }
}

#Preview(as: .systemSmall) {
    CryptoPriceWidget()
} timeline: {
    CryptoPriceEntry(
        date: Date(),
        name: "Bitcoin",
        symbol: "BTC"
    )
}
