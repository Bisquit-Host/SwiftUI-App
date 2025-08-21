import SwiftUI
import PteroNet

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let id: String
    private let backupLimit: Int
    
    init(_ server: ServerAttributes) {
        self.id = server.id
        self.backupLimit = server.featureLimits.backups
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.backups) { backup in
                BackupCard(id, backup)
#if !os(tvOS)
                    .focusable() // Applies to DB's & schedules as well
#endif
            }
            .onDelete { indexSet in
                Task {
                    await vm.deleteBackups(indexSet)
                }
            }
            
            CreateBackupButton(backupLimit)
        } header: {
            if !vm.backups.isEmpty {
                SectionHeader("Backups", type: .backup(vm.backups.count, limit: backupLimit))
            }
        }
        .environment(vm)
    }
}

#Preview {
    List {
        BackupList(sampleJSON(.serverListAttributes))
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
