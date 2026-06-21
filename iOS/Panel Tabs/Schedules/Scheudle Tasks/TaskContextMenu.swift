import SwiftUI
import Calagopus

struct TaskContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: ScheduleAttributes
    private let task: ScheduleTaskAttributes
    
    init(_ schedule: ScheduleAttributes, task: ScheduleTaskAttributes) {
        self.schedule = schedule
        self.task = task
    }
    
    var body: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            Task {
                await vm.deleteScheduleTask(schedule.id, taskId: task.id)
            }
        }
    }
}
