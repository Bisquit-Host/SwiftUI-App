import ScrechKit
import PteroNet

struct ScheduleList: View {
    @Environment(ScheduleVM.self) private var vm
    
    var body: some View {
        Section {
            ForEach(vm.schedules) { schedule in
                let tasks = schedule.relationships.tasks.data.map(\.attributes)
#if os(tvOS)
                ScheduleCard(schedule)
                
                ForEach(tasks) { task in
                    ScheduleTask(schedule, task: task)
                        .padding(.leading, 64)
                }
#else
                if tasks.isEmpty {
                    ScheduleCard(schedule)
                } else {
                    DisclosureGroup {
                        ForEach(tasks) { task in
                            ScheduleTask(schedule, task: task)
                        }
                    } label: {
                        ScheduleCard(schedule)
                    }
                }
#endif
            }
            
            Button("Create Schedule") {
                vm.sheetCreate = true
            }
#if os(tvOS)
            .buttonStyle(.borderedProminent)
#endif
        } header: {
            Text("Schedules")
                .bold()
        }
    }
}
