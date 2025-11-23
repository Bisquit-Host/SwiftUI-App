import WidgetKit
import PteroNet

struct ResourcesUsageEntry: TimelineEntry {
    let date: Date
    let name: String
    let id: String
    let state: String
    let test: ResourceUsageAttributes?
    
    init(date: Date, name: String, id: String, state: String, test: ResourceUsageAttributes? = nil) {
        self.date = date
        self.name = name
        self.id = id
        self.state = state
        self.test = test
    }
}
