import SwiftUI
import Calagopus

struct ScheduleTriggerRow: View {
    @Binding private var trigger: CalagopusScheduleTrigger
    
    init(_ trigger: Binding<CalagopusScheduleTrigger>) {
        self._trigger = trigger
    }
    
    var body: some View {
        Picker("Type", selection: $trigger.type) {
            ForEach(CalagopusScheduleTriggerType.allCases) {
                Text($0.scheduleLabel)
                    .tag($0)
            }
        }
        
        switch trigger.type {
        case .cron:
            TextField("Cron schedule", text: $trigger.schedule)
                .textInputAutocapitalization(.never)
            
        case .powerAction:
            Picker("Power action", selection: $trigger.action) {
                Text("Start").tag("start")
                Text("Stop").tag("stop")
                Text("Restart").tag("restart")
                Text("Kill").tag("kill")
            }
            
        case .serverState:
            Picker("State", selection: $trigger.state) {
                Text("Offline").tag("offline")
                Text("Starting").tag("starting")
                Text("Stopping").tag("stopping")
                Text("Running").tag("running")
            }
            
        case .backupStatus:
            Picker("Status", selection: $trigger.status) {
                Text("Starting").tag("starting")
                Text("Finished").tag("finished")
                Text("Failed").tag("failed")
            }
            
        case .consoleLine:
            TextField("Contains", text: $trigger.contains)
                .textInputAutocapitalization(.never)
            
            Toggle("Case insensitive", isOn: $trigger.caseInsensitive)
            
        case .crash:
            EmptyView()
        }
    }
}
