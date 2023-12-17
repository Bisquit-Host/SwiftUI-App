import SwiftUI
import PteroNet

struct ScheduleCard: View {
    @Environment(DataTabVM.self) private var vm
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
    
#if os(tvOS)
    private let spacing: CGFloat = 16
#else
    private let spacing: CGFloat = 6
#endif
    
    var body: some View {
        @Bindable var binding = vm
        
        Button {
            
        } label: {
            HStack {
                Image(systemName: "calendar")
                    .title2(.semibold)
                    .symbolRenderingMode(.multicolor)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: spacing) {
                        Text(schedule.name)
                            .title3()
                        
                        Circle()
                            .background(schedule.isActive ? .green : .red, in: .circle)
                            .foregroundStyle(schedule.isActive ? .green : .red)
#if os(tvOS)
                            .frame(width: 24)
#else
                            .frame(width: 12)
#endif
                    }
                    
                    Text("Cron: \(cron)")
                        .footnote()
                }
                
                Spacer()
            }
            .foregroundStyle(.foreground)
        }
#if !os(tvOS)
        .swipeActions {
            Button(role: .destructive) {
                vm.deleteSchedule(schedule.id)
            } label: {
                Image(systemName: "trash")
            }
        }
#endif
        .contextMenu {
            ScheduleContextMenu(schedule)
                .environment(vm)
        }
        .sheet($binding.sheetCreateTask) {
            NewTaskSheet(schedule.id)
        }
    }
}
