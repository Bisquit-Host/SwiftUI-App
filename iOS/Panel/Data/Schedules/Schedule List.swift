import ScrechKit
import PteroNet

struct ScheduleList: View {
    @Environment(DataTabVM.self) private var vm
    
    @State private var sheetCreateSchedule = false
    
    var body: some View {
        Section {
            ForEach(vm.schedules, id: \.attributes.id) { attributes in
                let schedule = attributes.attributes
                let tasks = schedule.relationships.tasks.data
#if os(tvOS)
                ScheduleCard(schedule)
                
                ForEach(tasks, id: \.attributes.action) { task in
                    ScheduleTask(schedule, task: task.attributes)
                        .padding(.leading, 64)
                }
#else
                DisclosureGroup {
                    ForEach(tasks, id: \.attributes.action) { task in
                        ScheduleTask(schedule, task: task.attributes)
                    }
                } label: {
                    ScheduleCard(schedule)
                }
#endif
            }
            
            Button {
                sheetCreateSchedule = true
            } label: {
                Text("Create Schedule")
            }
#if os(tvOS)
            .buttonStyle(.borderedProminent)
#endif
        } header: {
            Text("Schedules")
                .bold()
        }
        .sheet($sheetCreateSchedule) {
            NewScheduleSheet()
        }
        .environment(vm)
    }
}
