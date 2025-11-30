import AppIntents

struct ConfigurationAppIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "CryptoPriceConfigurationIntent"
    static let title: LocalizedStringResource = "Configuration"
    static let description = IntentDescription("Widget configuration")
    static let isDiscoverable = false
    
    @Parameter(title: "Server")
    var selectedServer: ServerIntentTypeAppEntity?
    
    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$selectedServer
        }
    }
}
