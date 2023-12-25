import SwiftUI

struct ScheduleList: View {
    @State private var vm: ScheduleVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = ScheduleVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.schedules, id: \.id) { schedule in
                    ScheduleCard(schedule)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Schedules")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            vm.fetchSchedules()
        }
        .onChange(of: id) {
            vm.fetchSchedules()
        }
    }
}

#Preview {
    ScheduleList("")
}
