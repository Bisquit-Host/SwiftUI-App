import ScrechKit

struct DatabaseInstanceStatusSection: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    var body: some View {
        Section {
            HStack {
                Image(systemName: vm.instance.type.symbol)
                    .title2(.semibold)
                    .frame(width: 32)
                
                VStack(alignment: .leading) {
                    Text(vm.instance.type.label)
                        .headline()
                    
                    Text(vm.state.title)
                        .footnote()
                        .foregroundStyle(vm.state.tint)
                }
                
                Spacer()
                
                if vm.instance.isLocked {
                    Image(systemName: "lock")
                        .secondary()
                }
            }
            
            if vm.isSuspended {
                Label("Suspended", systemImage: "pause.circle")
                    .foregroundStyle(.orange)
            }
            
            if let address = vm.instance.address {
                DatabaseDetailsRow("Address", value: address, privacySensitive: true)
            }
            
            DatabaseInstancePowerButtons()
        }
    }
}

#Preview {
    List {
        DatabaseInstanceStatusSection()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
