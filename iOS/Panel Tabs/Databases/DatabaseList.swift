import ScrechKit

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ databaseLimit: Int = 0) {
        self.databaseLimit = databaseLimit
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        if databaseLimit == 0 {
            ContentUnavailableView(
                "Databases are unavailable",
                systemImage: "externaldrive.badge.xmark"
            )
        } else {
            Section {
                ForEach(vm.databases) {
                    DatabaseCard($0)
                        .environment(vm)
                }
                //            .onDelete { offsets in
                //                vm.deleteItems(.databases, offsets: offsets)
                //            }
            } header: {
                if !vm.databases.isEmpty {
                    SectionHeader(
                        "Databases",
                        type: .database(
                            vm.databases.count,
                            limit: databaseLimit
                        )
                    )
                }
            }
            
            Section {
                Button("Create Database") {
                    vm.alertCreate = true
                }
                .foregroundStyle(.foreground)
                .disabled(vm.databases.count >= databaseLimit)
#if os(tvOS)
                .buttonStyle(.borderedProminent)
#endif
            }
        }
    }
}

#Preview {
    List {
        DatabaseList(4)
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
