import SwiftUI
import WidgetKit

struct BillingBalanceWidget: Widget {
    private let kind = "Billing Balance"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: GetBillingTotalBalanceIntent.self, provider: BillingBalanceTimelineProvider()) {
            BillingBalanceWidgetView($0)
        }
        .configurationDisplayName("Billing Balance")
        .description("View your total billing balance")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    BillingBalanceWidget()
} timeline: {
    BillingBalanceEntry(date: .now, balance: "€ 12.50", state: .loaded)
    BillingBalanceEntry(date: .now, balance: "Sign in", state: .notSignedIn)
}
