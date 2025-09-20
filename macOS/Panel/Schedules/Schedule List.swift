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
    }
}

#Preview {
    NavigationStack {
        ScheduleList("")
    }
    .environment(ScheduleVM(""))
}
