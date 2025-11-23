import ScrechKit

struct PowerWidgetView: View {
    private let entry: ResourcesUsageEntry
    
    init(_ entry: ResourcesUsageEntry) {
        self.entry = entry
    }
    
    var body: some View {
        let id = entry.id
        
        if id.isEmpty || id.count != 8 {
            ConfigureWidgetView("Bisquit.Host", image: Image(.defaultIcon), lastStep: "3. **Choose a server** from the list")
        } else {
            VStack {
                Text(id)
                
                HStack {
                    Button(intent: StartServerIntent(id)) {
                        Text("Start")
                    }
                    
                    Button(role: .destructive, intent: StopServerIntent(id)) {
                        Text("Stop")
                    }
                }
                
                Button(intent: RestartServerIntent(id)) {
                    Text("Restart")
                }
            }
        }
    }
}
