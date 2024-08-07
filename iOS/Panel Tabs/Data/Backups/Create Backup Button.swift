import SwiftUI

struct CreateBackupButton: View {
    @Environment(BackupVM.self) private var vm
    
    private let backupLimit: Int
    
    init(_ backupLimit: Int) {
        self.backupLimit = backupLimit
    }
    
    var body: some View {
        Button("Create Backup") {
            vm.alertCreateBackup = true
        }
        .disabled(vm.backups.count >= backupLimit)
    }
}

#Preview {
    CreateBackupButton(4)
        .environment(BackupVM(""))
}
