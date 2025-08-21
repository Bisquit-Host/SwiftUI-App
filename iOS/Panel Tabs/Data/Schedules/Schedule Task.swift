import ScrechKit
import PteroNet

struct ScheduleTask: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: ScheduleAttributes
    private let task: ScheduleTaskAttributes
    
    init(_ schedule: ScheduleAttributes, task: ScheduleTaskAttributes) {
        self.schedule = schedule
        self.task = task
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: getIcon(task.action))
                    .foregroundStyle(.gray)
                    .semibold()
#if os(tvOS)
                    .title2()
#endif
                
                VStack(alignment: .leading) {
                    Text(task.action.capitalized)
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

//#Preview {
//    List {
//        ScheduleTask(
//            sampleJSON(.),
//            task: sampleJSON(.)
//        )
//    }
//    .darkSchemePreferred()
//}
