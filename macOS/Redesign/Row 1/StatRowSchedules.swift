import SwiftUI

struct StatRowSchedules: View {
    @State private var vm: ScheduleVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = ScheduleVM(id)
    }
    
    @State private var sheetSchedules = false
    
    var body: some View {
        Button {
            sheetSchedules = true
        } label: {
            StatTile("Schedules", value: vm.schedules.count, icon: "calendar")
        }
        .task {
            await vm.fetchSchedules()
        }
        .sheet($sheetSchedules) {
            ScheduleList(id)
                .environment(vm)
        }
    }
}

#Preview {
    StatRowSchedules("")
}
