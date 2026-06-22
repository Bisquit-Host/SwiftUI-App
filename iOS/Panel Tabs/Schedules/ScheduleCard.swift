import SwiftUI
import Calagopus

struct ScheduleCard: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: CalagopusServerSchedule
    
    init(_ schedule: CalagopusServerSchedule) {
        self.schedule = schedule
    }
    
    private var cron: String {
        guard
            case .object(let trigger) = schedule.triggers.first,
            case .string(let schedule) = trigger["schedule"]
        else {
            return "-"
        }
        
        return schedule
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
                    
                    Text(cron)
                        .footnote()
                        .secondary()
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
