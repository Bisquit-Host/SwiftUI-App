import SwiftUI
import PteroNet

struct AllocationList: View {
    @Environment(AllocationVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.allocations) {
                AllocationCard($0)
            }
            
            Section {
                Button("Assign allocation", systemImage: "plus") {
                    sheetCreate = true
                }
                .disabled(vm.allocations.count >= server.featureLimits.allocations)
            }
        }
        .navigationTitle("Allocations")
        .animation(.default, value: vm.allocations.count)
        .task {
            await vm.fetchAllocations()
        }
        .sheet($sheetCreate) {
            SheetCreateAllocation()
        }
    }
}

#Preview {
    NavigationStack {
        AllocationList(PreviewProp.serverAttributes)
    }
    .environment(AllocationVM(""))
}
