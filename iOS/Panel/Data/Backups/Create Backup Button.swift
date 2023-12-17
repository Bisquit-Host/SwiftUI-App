import SwiftUI

struct CreateBackupButton: View {
    @Environment(DataTabVM.self) private var vm
    
    private let backupLimit: Int
    
    init(_ backupLimit: Int) {
        self.backupLimit = backupLimit
    }
    
    var body: some View {
        Menu("Create Backup") {
            Button {
                vm.alertCreateBackup = true
            } label: {
                Label("Name Backup", systemImage: "pencil")
            }
        } primaryAction: {
            vm.createBackup()
        }
        .disabled(vm.backups.count >= backupLimit)
    }
}

#Preview {
    CreateBackupButton(4)
        .environment(DataTabVM(""))
}
