import SwiftUI
import Calagopus

struct BackupTab: View {
    @Environment(BackupVM.self) private var vm
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            if vm.backups.isEmpty {
                ContentUnavailableView(
                    "No backups yet",
                    systemImage: "doc.zipper",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
            
            Section {
                ForEach(vm.backups) {
                    BackupCard($0)
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
            
            Button("Create", role: .confirm, action: createBackup)
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
        BackupTab(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
