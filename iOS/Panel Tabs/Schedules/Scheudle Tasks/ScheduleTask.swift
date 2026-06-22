import ScrechKit
import Calagopus

struct ScheduleTask: View {
    private let schedule: CalagopusServerSchedule
    private let task: CalagopusServerScheduleStep
    
    init(_ schedule: CalagopusServerSchedule, task: CalagopusServerScheduleStep) {
        self.schedule = schedule
        self.task = task
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: getIcon(task.actionName))
                    .foregroundStyle(.gray)
                    .semibold()
#if os(tvOS)
                    .title2()
#endif
                
                VStack(alignment: .leading) {
                    Text(task.actionName.capitalized)
                        .subheadline()
                    
                    let offset = Text(task.timeOffset == 0 ? "-" : "\(task.timeOffset)")
                        .foregroundStyle(.primary)
                    
                    Text("Time offset: \(offset)")
                        .secondary()
                    
                    let payload = Text(task.payload)
                        .foregroundStyle(.primary)
                    
                    Text("Payload: \(payload)")
                        .secondary()
                        .lineLimit(1)
                }
                .caption2()
            }
            .foregroundStyle(.foreground)
        }
        .contextMenu {
            TaskContextMenu(schedule, task: task)
        }
    }
    
    private func getIcon(_ action: String) -> String {
        switch action {
        case "backup":
            "externaldrive.badge.icloud"
            
        case "power":
            "bolt"
            
        case "command":
            "terminal"
            
        default:
            "exclamationmark.triangle"
        }
    }
}

private extension CalagopusServerScheduleStep {
    var actionObject: [String: CalagopusJSON] {
        guard case .object(let object) = action else {
            return [:]
        }
        
        return object
    }
    
    var actionName: String {
        switch actionType {
        case "send_command":
            "command"
        case "send_power":
            "power"
        case "create_backup":
            "backup"
        default:
            actionType
        }
    }
    
    var payload: String {
        switch actionType {
        case "send_command":
            actionObject["command"]?.displayString ?? ""
        case "send_power":
            actionObject["action"]?.displayString ?? ""
        case "create_backup":
            actionObject["name"]?.displayString ?? ""
        case "sleep":
            actionObject["duration"]?.displayString ?? ""
        default:
            ""
        }
    }
    
    var timeOffset: Int {
        guard actionType == "sleep" else {
            return 0
        }
        
        return actionObject["duration"]?.scheduleIntValue ?? 0
    }
    
    private var actionType: String {
        actionObject["type"]?.displayString ?? ""
    }
}

private extension CalagopusJSON {
    var displayString: String {
        switch self {
        case .null:
            ""
        case .bool(let value):
            value.description
        case .number(let value):
            if value.rounded() == value {
                Int(value).description
            } else {
                value.description
            }
        case .string(let value):
            value
        case .array, .object:
            ""
        }
    }
    
    var scheduleIntValue: Int? {
        switch self {
        case .number(let value):
            Int(value)
        case .string(let value):
            Int(value)
        default:
            nil
        }
    }
}

//#Preview {
//    List {
//        ScheduleTask(
//            PreviewProp.scheduleAttributes,
//            task: PreviewProp.scheduleTaskAttributes
//        )
//    }
//    .darkSchemePreferred()
//}
