import ScrechKit

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.databases) {
                DatabaseCard($0)
                    .environment(vm)
            }
            //            .onDelete { offsets in
            //                vm.deleteItems(.databases, offsets: offsets)
            //            }
        }
    }
}

#Preview {
    List {
        DatabaseList()
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
