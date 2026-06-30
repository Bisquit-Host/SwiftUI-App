import SwiftUI
import Calagopus

struct ScheduleCard: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: CalagopusServerSchedule
    
    init(_ schedule: CalagopusServerSchedule) {
        self.schedule = schedule
    }
    
    private var triggerSummary: String {
        let summaries = schedule.triggers.map(\.scheduleTriggerSummary)
        
        guard !summaries.isEmpty else {
            return "-"
        }
        
        return summaries.joined(separator: ", ")
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Button {
            
        } label: {
            HStack {
                Image(systemName: "calendar")
                    .title2(.semibold)
                    .symbolRenderingMode(.multicolor)
                    .frame(width: 32)
                    .foregroundStyle(schedule.enabled ? .green : .red)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(schedule.name)
                        .headline()
                    
                    Text(triggerSummary)
                        .footnote()
                        .secondary()
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .foregroundStyle(.foreground)
        }
        .contextMenu {
            ScheduleContextMenu(schedule)
                .environment(vm)
        }
        .sheet($vm.sheetCreateTask) {
            NewTaskSheet(schedule.id)
        }
    }
}

private extension CalagopusJSON {
    var scheduleTriggerSummary: String {
        guard case .object(let object) = self else {
            return "-"
        }
        
        let type = object["type"]?.scheduleDisplayString ?? ""
        
        switch type {
        case "cron":
            return object["schedule"]?.scheduleDisplayString ?? "Cron"
            
        case "power_action":
            return "Power \(object["action"]?.scheduleDisplayString ?? "")"
            
        case "server_state":
            return "State \(object["state"]?.scheduleDisplayString ?? "")"
            
        case "backup_status":
            return "Backup \(object["status"]?.scheduleDisplayString ?? "")"
        
        case "console_line":
            return "Console \(object["contains"]?.scheduleDisplayString ?? "")"
        
        case "crash":
            return "Crash"
        
        default:
            return type
        }
    }
    
    private var scheduleDisplayString: String {
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
}
