import SwiftUI
import Calagopus

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let id: String
    
    init(_ server: CalagopusServer) {
        self.id = server.id
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.backups) {
                BackupCard(id, $0)
#if !os(tvOS)
                    .focusable()
#endif
            }
            .onDelete { indexSet in
                Task {
                    await vm.deleteBackups(indexSet)
                }
            }
        }
    }
}

#Preview {
    List {
        BackupList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
