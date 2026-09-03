import SwiftUI

struct ScheduleTab: View {
    @Environment(ScheduleVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        List {
            ScheduleList()
        }
        .scrollIndicators(.never)
        .overlay {
            if vm.isLoadingSchedules && vm.schedules.isEmpty {
                ProgressView()
            } else if vm.hasFinishedLoadingSchedules && vm.schedules.isEmpty {
                ScheduleListEmptyState()
            }
        }
        .frame(maxWidth: 500)
        .refreshableTask {
            await vm.fetchSchedules()
        }
        .sheet($vm.sheetCreate) {
            NavigationStack {
                NewScheduleSheet()
            }
        }
        .toolbar {
            PanelToolbarItem(placement: .topBarTrailing) {
                Button("Create Schedule", systemImage: "calendar.badge.plus") {
                    vm.sheetCreate = true
                }
            }
        }
    }
}

#Preview {
    ScheduleTab()
        .darkSchemePreferred()
        .environment(ScheduleVM(""))
}
