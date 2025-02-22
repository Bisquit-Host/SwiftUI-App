import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget")
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String?
}
