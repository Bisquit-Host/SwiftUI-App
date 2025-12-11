import SwiftUI

struct VDSHistorySection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Action history")
                .subheadline(.semibold)
            
            if vm.history.isEmpty {
                Text("No actions yet")
                    .secondary()
                    .footnote()
            } else {
                ForEach(vm.history) {
                    VDSHistoryItem($0)
                }
            }
        }
    }
}
