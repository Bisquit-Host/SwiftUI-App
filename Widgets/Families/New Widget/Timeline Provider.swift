import WidgetKit

struct CryptoPriceTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ResourcesUsageEntry {
        ResourcesUsageEntry(
            date: Date(),
            name: "Preview",
            id: "12345678",
            state: "running"
        )
    }
    
    func getSnapshot(
        for configuration: CryptoPriceConfigurationIntent,
        in context: Context,
        completion: @escaping (ResourcesUsageEntry) -> ()
    ) {
        let entry = ResourcesUsageEntry(
            date: Date(),
            name: "Preview",
            id: "12345678",
            state: "running"
        )
        
        completion(entry)
    }
    
    func getTimeline(
        for configuration: CryptoPriceConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<ResourcesUsageEntry>) -> ()
    ) {
        // Extract info from configuration
        
        guard
            let name = configuration.selectedServer?.name,
            let id = configuration.selectedServer?.id
        else {
            showEmptyState(completion, error: "1")
            return
        }
        
        Task {
            // Fetch asset details
            let assetDetails = await AssetFetcher.fetchAssetDetails(id)
            
            // Create Entry using based on user selected configuration & fetched info
            let entry = ResourcesUsageEntry(
                date: Date(),
                name: name,
                id: id,
                state: assetDetails.state,
                test: assetDetails.test
            )
            
            // Trigger completion & next fetch in 15 mins
            executeTimelineCompletion(completion, timelineEntry: entry)
        }
    }
    
    private func showEmptyState(
        _ completion: @escaping (Timeline<ResourcesUsageEntry>) -> (),
        error: String
    ) {
        let entry = ResourcesUsageEntry(
            date: Date(),
            name: "",
            id: "",
            state: error
        )
        
        // Trigger completion & next fetch in 15 mins
        executeTimelineCompletion(completion, timelineEntry: entry)
    }
    
    func executeTimelineCompletion(
        _ completion: @escaping (Timeline<ResourcesUsageEntry>) -> (),
        timelineEntry: ResourcesUsageEntry
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
