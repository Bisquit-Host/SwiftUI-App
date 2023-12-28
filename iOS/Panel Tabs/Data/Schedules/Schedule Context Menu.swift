import ScrechKit
import PteroNet

struct ScheduleContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: ScheduleAttributes
    
    init(_ schedule: ScheduleAttributes) {
        self.schedule = schedule
    }
    
    var body: some View {
        MenuButton("Create task", icon: "plus") {
            vm.sheetCreateTask = true
        }
        
        MenuButton("Execute", icon: "play") {
            vm.executeSchedule(schedule.id)
        }
        
        Section {
            MenuButton("Delete", role: .destructive, icon: "trash") {
                vm.deleteSchedule(schedule.id.description)
            }
        }
    }
}
