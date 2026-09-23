import ScrechKit
import Calagopus

struct TaskContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: CalagopusServerSchedule
    private let task: CalagopusServerScheduleStep
    
    init(_ schedule: CalagopusServerSchedule, task: CalagopusServerScheduleStep) {
        self.schedule = schedule
        self.task = task
    }
    
    var body: some View {
        AsyncButton("Delete", systemImage: "trash", role: .destructive) {
            await vm.deleteScheduleTask(schedule.id, taskId: task.id)
        }
    }
}
