import WidgetKit

struct Static_Provider: TimelineProvider {
    func placeholder(in context: Context) -> StaticEntry {
        StaticEntry(date: Date())
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (StaticEntry) -> ()
    ) {
        let entry = StaticEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<StaticEntry>) -> ()
    ) {
        let entry = StaticEntry(date: Date())
        
        let timeline = Timeline(
            entries: [entry],
            policy: .never
        )
        
        completion(timeline)
    }
}
