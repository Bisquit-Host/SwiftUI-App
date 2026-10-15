import ScrechKit
import Calagopus

struct DatabaseInstanceCard: View {
    @Environment(DatabaseInstanceVM.self) private var vm
#if os(iOS)
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
#endif
    private let instance: CalagopusDatabaseInstance
    
    init(_ instance: CalagopusDatabaseInstance) {
        self.instance = instance
    }
    
    @State private var alertDelete = false
    
    var body: some View {
        Button {
            vm.detailsInstance = instance
        } label: {
            HStack {
                Image(systemName: instance.type.symbol)
                    .title2(.semibold)
                    .frame(width: 32)
                
                VStack(alignment: .leading) {
                    Text(instance.name)
                        .headline()
                    
                    Text(instance.address ?? instance.type.label)
                        .footnote()
                        .secondary()
                }
                .minimumScaleFactor(0.25)
                .lineLimit(1)
                
                Spacer()
                
                if instance.isLocked {
                    Image(systemName: "lock")
                        .secondary()
                }
                
                Text(instance.type.label)
                    .caption()
                    .secondary()
            }
            .foregroundStyle(.foreground)
        }
        .swipeActions {
            if !instance.isLocked {
                Button("Delete", systemImage: "trash") {
                    alertDelete = true
                }
                .labelStyle(.iconOnly)
                .tint(.red)
            }
        }
        .contextMenu {
            Button("Details", systemImage: "info.circle") {
                vm.detailsInstance = instance
            }
            
            Section {
                AsyncButton("Start", systemImage: "play") {
                    await vm.power(instance.id, action: .start)
                }
                
                AsyncButton("Restart", systemImage: "arrow.clockwise") {
                    await vm.power(instance.id, action: .restart)
                }
                
                AsyncButton("Stop", systemImage: "stop") {
                    await vm.power(instance.id, action: .stop)
                }
            }
            
            if !instance.isLocked {
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    alertDelete = true
                }
            }
        }
        .alert("Delete Managed Database", isPresented: $alertDelete) {
            AsyncButton("Delete", role: .destructive, action: delete)
        } message: {
            Text("Are you sure you want to delete \"\(instance.name)\"? All of its databases and users will be deleted immediately. You can't undo this action")
        }
    }
    
    private func delete() async {
#if os(iOS)
        if store.useBiometry, await !biometry.authenticate() {
            SystemAlert.error("Biometry authentication failed")
            return
        }
#endif
        _ = await vm.deleteInstance(instance.id)
    }
}

#Preview {
    List {
        DatabaseInstanceCard(PreviewProp.databaseInstance)
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceVM(""))
}
