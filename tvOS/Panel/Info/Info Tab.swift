import SwiftUI
import PteroNet

struct InfoTab: View {
    private let id: String
    private var allocationVM: AllocationVM
    private var startupVM: StartupVM
    @Environment(NavState.self) private var navState
    
    init(_ id: String) {
        self.id = id
        self.allocationVM = AllocationVM(id)
        self.startupVM = StartupVM(id)
    }
    
    var body: some View {
        HStack {
            NavigationLink {
                AllocationList()
                    .environment(allocationVM)
            } label: {
                Label("Allocations", systemImage: "network")
                    .frame(width: 500, height: 250)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
            }
            
            NavigationLink {
                StartupList()
                    .environment(startupVM)
            } label: {
                Label("Startup", systemImage: "airplane")
                    .frame(width: 500, height: 250)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
            }
        }
        .title2()
        .buttonStyle(.plain)
        .task {
            allocationVM.fetchAllocations()
            startupVM.fetchStartupVariables()
        }
    }
}

#Preview {
    NavigationView {
        InfoTab("")
    }
    .environment(AllocationVM(""))
    .environment(StartupVM(""))
    .environment(NavState())
}
