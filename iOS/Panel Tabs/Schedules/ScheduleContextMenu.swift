import SwiftUI
import Calagopus

struct ScheduleContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: ScheduleAttributes
    
    init(_ schedule: ScheduleAttributes) {
        self.schedule = schedule
    }
    
    var body: some View {
        ControlGroup {
            Button("Execute", systemImage: "play") {
                Task {
                    await vm.executeSchedule(schedule.id)
                }
            }
            
            Button("New task", systemImage: "plus") {
                vm.sheetCreateTask = true
            }
        }
        
        Divider()
        
        Button("Delete", systemImage: "trash", role: .destructive) {
            Task {
                await vm.deleteSchedule(schedule.id.description)
            }
        }
    }
}
