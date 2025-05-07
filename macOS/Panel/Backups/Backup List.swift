import SwiftUI
import PteroNet

struct BackupList: View {
    @State private var vm: BackupVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = BackupVM(server.id)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(vm.backups, id: \.uuid) { backup in
                    BackupCard(backup)
                }
            }
            
            Text("\(vm.backups.count) / \(server.featureLimits.backups) backups used")
            
            Button("Create backup") {
                vm.alertCreateBackup = true
            }
            .disabled(vm.backups.count >= server.featureLimits.backups)
        }
        .environment(vm)
        .navigationTitle("Backups")
        .padding()
        .task {
            vm.fetchBackups()
        }
        .onChange(of: server.id) {
            vm.fetchBackups()
        }
        .alert("Name Backup", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Cancel", role: .cancel) {}
            
            Button("Create") {
                vm.createBackup()
            }
        }
    }
}

#Preview {
    BackupList(sampleJSON(.serverListAttributes))
}
