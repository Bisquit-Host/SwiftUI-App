import ScrechKit
import Calagopus

struct ScheduleContextMenu: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let schedule: CalagopusServerSchedule
    
    init(_ schedule: CalagopusServerSchedule) {
        self.schedule = schedule
    }
    
    var body: some View {
        ControlGroup {
            AsyncButton("Execute", systemImage: "play") {
                await vm.executeSchedule(schedule.id)
            }
            
            Button("New task", systemImage: "plus") {
                vm.sheetCreateTask = true
            }
        }
        
        Divider()
        
        AsyncButton("Delete", systemImage: "trash", role: .destructive) {
            await vm.deleteSchedule(schedule.id)
        }
    }
}
