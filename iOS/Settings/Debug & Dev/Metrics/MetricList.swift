import SwiftUI

struct MetricList: View {
    @State private var vm = MetricListVM()
    
    var body: some View {
        List {
            if vm.files.isEmpty {
                Text("No metrics saved yet")
                    .secondary()
            } else {
                ForEach(vm.files, id: \.self) {
                    MetricCard($0)
                }
            }
        }
        .navigationTitle("Metrics")
        .refreshableTask {
            vm.loadFiles()
        }
    }
}
