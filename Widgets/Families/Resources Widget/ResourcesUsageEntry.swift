import WidgetKit
import Calagopus

struct ResourcesUsageEntry: TimelineEntry {
    let date: Date
    let name: String
    let id: String
    let state: String
    let test: CalagopusResourceUsage?
    
    init(date: Date, name: String, id: String, state: String, test: CalagopusResourceUsage? = nil) {
        self.date = date
        self.name = name
        self.id = id
        self.state = state
        self.test = test
    }
}
