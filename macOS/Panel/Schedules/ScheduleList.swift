import SwiftUI

struct ScheduleList: View {
    @Environment(ScheduleVM.self) private var vm
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.schedules) {
                    ScheduleCard($0)
                }
            }
        }
        .navigationTitle("Schedules")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            await vm.fetchSchedules()
        }
        .overlay {
            if vm.schedules.isEmpty {
                ContentUnavailableView(
                    "No schedules have been created yet",
                    systemImage: "calendar.badge.plus",
                    //                    description: Text("Use the button in the top right corner to create one")
                )
#warning("uncomment")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleList("")
    }
    .darkSchemePreferred()
    .environment(ScheduleVM(""))
}
