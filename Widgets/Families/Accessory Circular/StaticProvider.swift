import WidgetKit

struct StaticProvider: TimelineProvider {
    func placeholder(in context: Context) -> StaticEntry {
        StaticEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StaticEntry) -> ()) {
        completion(StaticEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StaticEntry>) -> ()) {
        let entry = StaticEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        
        completion(timeline)
    }
}
