import SwiftUI
import PteroNet

struct WatchBackupTab: View {
    @Environment(BackupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                ForEach(vm.backups) {
                    WatchBackupCard($0)
                }
            } header: {
                Text("\(vm.backups.count) / \(server.featureLimits.backups)")
            }
            
            Section {
                Button("Create Backup", systemImage: "plus", action: showCreateBackupAlert)
                    .disabled(vm.backups.count >= server.featureLimits.backups)
            }
        }
        .navigationTitle("Backups")
        .task {
            await vm.fetchBackups()
        }
        .refreshable {
            await vm.fetchBackups()
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .textInputAutocapitalization(.never)
            
            Button("Create", role: .confirmy, action: createBackup)
            Button("Cancel", role: .cancel) {
                vm.textCreateBackup = ""
            }
        }
    }
    
    private func showCreateBackupAlert() {
        vm.alertCreateBackup = true
    }
    
    private func createBackup() {
        Task {
            await vm.createBackup()
        }
    }
}

#Preview {
    NavigationStack {
        WatchBackupTab(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
