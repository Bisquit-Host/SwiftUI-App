import ScrechKit

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let backupLimit: Int
    
    init(_ backupLimit: Int) {
        self.backupLimit = backupLimit
    }
    
    var body: some View {
        @Bindable var binding = vm
        
        Section {
            ForEach(vm.backups, id: \.uuid) { backup in
                BackupCard(backup)
            }
            .onDelete { offsets in
                vm.deleteBackups(offsets)
            }
            
            CreateBackupButton(backupLimit)
        } header: {
            SectionHeader("Backups",
                          type: .backup(vm.backups.count, limit: backupLimit))
        }
#if os(tvOS)
        .sheet($binding.showSafari) {
            QRCodeView(vm.downloadUrl)
        }
#else
        .safariCover($binding.showSafari, url: vm.downloadUrl)
#endif
        .environment(vm)
        .alert("Name Backup", isPresented: $binding.alertCreateBackup) {
            TextField("Cool backup", text: $binding.textCreateBackup)
                .autocorrectionDisabled()
            
            Button("Create") {
                vm.createBackup()
            }
        }
    }
}

#Preview {
    List {
        BackupList(4)
            .environment(BackupVM(""))
    }
}
