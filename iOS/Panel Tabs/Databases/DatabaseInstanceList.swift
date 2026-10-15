import ScrechKit

struct DatabaseInstanceList: View {
    @Environment(DatabaseInstanceVM.self) private var vm
    
    var body: some View {
        Section {
            ForEach(vm.instances) {
                DatabaseInstanceCard($0)
            }
        }
    }
}

#Preview {
    List {
        DatabaseInstanceList()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceVM(""))
}
