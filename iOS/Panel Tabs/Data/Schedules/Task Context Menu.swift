import ScrechKit
import PteroNet

struct TaskContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: ScheduleAttributes
    private let task: ScheduleTaskAttributes
    
    init(_ schedule: ScheduleAttributes, task: ScheduleTaskAttributes) {
        self.schedule = schedule
        self.task = task
    }
    
    var body: some View {
        MenuButton("Delete", role: .destructive, icon: "trash") {
            Task {
                await vm.deleteScheduleTask(schedule.id, taskId: task.id)
            }
        }
    }
}
