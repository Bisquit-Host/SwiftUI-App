import AppIntents
import WidgetKit

struct BillingBalanceTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BillingBalanceEntry {
        BillingBalanceEntry(date: .now, balance: "€ 0", state: .loaded)
    }
    
    func snapshot(for configuration: GetBillingTotalBalanceIntent, in context: Context) async -> BillingBalanceEntry {
        BillingBalanceEntry(date: .now, balance: "€ 0", state: .loaded)
    }
    
    func timeline(for configuration: GetBillingTotalBalanceIntent, in context: Context) async -> Timeline<BillingBalanceEntry> {
        let entry = await entry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func entry() async -> BillingBalanceEntry {
        do {
            let balance = try await BillingTotalBalanceService.loadFormattedBalance()
            return BillingBalanceEntry(date: .now, balance: balance, state: .loaded)
        } catch BillingBalanceIntentError.notSignedIn {
            return BillingBalanceEntry(date: .now, balance: "Sign in", state: .notSignedIn)
        } catch {
            return BillingBalanceEntry(date: .now, balance: "Unavailable", state: .unavailable)
        }
    }
}
