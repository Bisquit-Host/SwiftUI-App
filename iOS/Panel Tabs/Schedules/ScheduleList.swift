import SwiftUI
import Calagopus

struct ScheduleList: View {
    @Environment(ScheduleVM.self) private var vm
    
    var body: some View {
        Section {
            ForEach(vm.schedules) { schedule in
                let tasks = vm.stepsByScheduleID[schedule.id] ?? []
                Group {
                    if tasks.isEmpty {
                        ScheduleCard(schedule)
                    } else {
                        DisclosureGroup {
                            ForEach(tasks) {
                                ScheduleTask(schedule, task: $0)
                            }
                        } label: {
                            ScheduleCard(schedule)
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await vm.deleteSchedule(schedule.id)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .task {
            await vm.fetchSchedulesIfNeeded()
        }
    }
}
