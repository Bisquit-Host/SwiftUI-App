extension ConfigurationAppIntent {
    static var empty: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.id = ""
        
        return intent
    }
    
    static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.id = "😀"
        
        return intent
    }
}
