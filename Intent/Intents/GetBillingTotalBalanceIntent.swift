#if os(iOS)
import AppIntents

struct GetBillingTotalBalanceIntent: AppIntent, WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Billing Total Balance"
    static let description = IntentDescription("Fetches your total billing balance")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get total balance")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let balance = try await BillingTotalBalanceService.loadFormattedBalance()
        return .result(value: balance, dialog: "Your total balance is \(balance)")
    }
}
#endif
