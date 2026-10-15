import ScrechKit

struct DatabaseTab: View {
    @Environment(DatabaseInstanceVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DatabaseInstanceList()
        }
        .panelContentMargins()
        .scrollIndicators(.never)
        .animation(.default, value: vm.instances)
        .overlay {
            DatabaseTabOverlay()
        }
        .refreshableTask {
            await vm.fetchInstances()
        }
        .toolbar {
            PanelToolbarItem {
                Button("Create Managed Database", systemImage: "externaldrive.badge.plus") {
                    vm.showCreateSheet = true
                }
                .labelStyle(.iconOnly)
                .disabled(vm.templates.isEmpty)
            }
        }
        .sheet(item: $vm.detailsInstance) {
            DatabaseInstanceDetailsSheetHost($0)
        }
        .sheet($vm.showCreateSheet) {
            NavigationStack {
                DatabaseInstanceCreateSheet()
            }
            .environment(vm)
        }
    }
}

#Preview {
    DatabaseTab()
        .darkSchemePreferred()
        .environment(DatabaseInstanceVM(""))
}
