import ScrechKit
import PteroNet

struct ScheduleContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: ScheduleAttributes
    
    init(_ schedule: ScheduleAttributes) {
        self.schedule = schedule
    }
    
    var body: some View {
        ControlGroup {
            MenuButton("Execute", icon: "play") {
                vm.executeSchedule(schedule.id)
            }
            
            MenuButton("New task", icon: "plus") {
                vm.sheetCreateTask = true
            }
        }
        
        Section {
            MenuButton("Delete", role: .destructive, icon: "trash") {
                Task {
                    await vm.deleteSchedule(schedule.id.description)
                }
            }
        }
    }
}
