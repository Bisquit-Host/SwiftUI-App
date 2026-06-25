import SwiftUI

struct ScheduleTab: View {
    @Environment(ScheduleVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        List {
            ScheduleList()
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollIndicators(.never)
#if !os(tvOS)
        .frame(maxWidth: 500)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .refreshableTask {
            await vm.fetchSchedules()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create Schedule", systemImage: "calendar.badge.plus") {
                    vm.sheetCreate = true
                }
            }
        }
        .sheet($vm.sheetCreate) {
            NewScheduleSheet()
        }
    }
}

#Preview {
    ScheduleTab()
        .darkSchemePreferred()
        .environment(ScheduleVM(""))
}
