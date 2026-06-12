import WidgetKit

struct BillingBalanceEntry: TimelineEntry {
    let date: Date
    let balance: String
    let state: BillingBalanceWidgetState
}
