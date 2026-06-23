import SwiftUI
import Calagopus

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let id: String
    private let backupLimit: Int
    
    init(_ server: CalagopusServer) {
        self.id = server.id
        self.backupLimit = server.featureLimits.backups
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        if vm.backups.isEmpty {
            BackupListEmptyState()
        } else {
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
            } header: {
                SectionHeader("Backups", type: .backup(vm.backups.count, limit: backupLimit))
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
