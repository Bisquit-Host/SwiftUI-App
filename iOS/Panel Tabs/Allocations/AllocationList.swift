import ScrechKit
import PteroNet

struct AllocationList: View {
    private var vm: AllocationVM
    private let server: ServerAttributes
    
    var showsDismissButton: Bool
    
    init(_ server: ServerAttributes, showsDismissButton: Bool = true) {
        self.server = server
        self.showsDismissButton = showsDismissButton
        vm = AllocationVM(server.id)
    }
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.allocations) {
                AllocationCard($0)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Allocations")
        .task {
            await vm.fetchAllocations()
        }
        .refreshableTask {
            await vm.fetchAllocations()
        }
        .sheet($sheetCreate) {
            NavigationStack {
                SheetCreateAllocation()
            }
        }
        .environment(vm)
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
#if os(iOS) || os(macOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            ToolbarItem(placement: .bottomBar) {
                SFButton("link.badge.plus") {
                    sheetCreate = true
                }
                .disabled(vm.allocations.count >= server.featureLimits.allocations)
            }
        }
    }
    
    private func delete(offsets: IndexSet) {
        for index in offsets {
            let id = vm.allocations[index].id
            
            Task {
                await vm.unassignAllocation(id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllocationList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
