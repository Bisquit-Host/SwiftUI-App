import SwiftUI

struct VDSServiceHistoryTab: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    let serviceId: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if vm.isLoading, vm.history.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                } else {
                    VDSHistorySection()
                }
            }
            .padding()
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
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
