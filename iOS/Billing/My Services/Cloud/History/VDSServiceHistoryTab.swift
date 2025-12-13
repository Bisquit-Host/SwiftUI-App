import SwiftUI

struct VDSServiceHistoryTab: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    let serviceId: Int
    
    var body: some View {
        List {
            if vm.isLoading, vm.history.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            } else {
                VDSHistorySection()
            }
        }
        .refreshableTask {
            await vm.load(serviceId)
        }
    }
}

#Preview("History Tab") {
    NavigationStack {
        VDSServiceHistoryTab(serviceId: 1)
            .environment(VDSServiceDetailsVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
