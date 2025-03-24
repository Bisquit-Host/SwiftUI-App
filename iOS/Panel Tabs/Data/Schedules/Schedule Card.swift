import SwiftUI
import PteroNet

struct ScheduleCard: View {
    @Environment(ScheduleVM.self) private var vm
    @Environment(NavState.self) private var navState
    
    private let schedule: ScheduleAttributes
    
    init(_ schedule: ScheduleAttributes) {
        self.schedule = schedule
    }
    
    @State private var isExtended = false
    
    private var cron: String {
        let cron = schedule.cron
        let dayOfMonth = cron.dayOfMonth
        let dayOfWeek = cron.dayOfWeek
        let hour = cron.hour
        let minute = cron.minute
        
        return dayOfMonth + dayOfWeek + hour + minute
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
                    .foregroundStyle(schedule.isActive ? .green : .red)
                
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
#if !os(tvOS)
        .swipeActions {
            Button(role: .destructive) {
                vm.deleteSchedule(schedule.id.description)
            } label: {
                Image(systemName: "trash")
            }
        }
#endif
        .contextMenu {
            ScheduleContextMenu(schedule)
                .environment(vm)
        }
        .sheet($vm.sheetCreateTask) {
            NewTaskSheet(schedule.id)
        }
    }
}
