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
                ForEach(vm.schedules) {
                    ScheduleCard($0)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Schedules")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            await vm.fetchSchedules()
        }
        .onChange(of: id) {
            Task {
                await vm.fetchSchedules()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleList("")
    }
}
