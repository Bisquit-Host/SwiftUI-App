import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let intentClassName = "ServerUsageIntent"
    
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget")
    
    @Parameter(title: "Server id", default: "")
    var serverId: String
}
