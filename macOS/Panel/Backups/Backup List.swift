import SwiftUI
import PteroNet

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(vm.backups) {
                    BackupCard($0)
                }
            }
            
            Text("\(vm.backups.count) / \(server.featureLimits.backups) backups used")
            
            Button("Create backup") {
                vm.alertCreateBackup = true
            }
            .disabled(vm.backups.count >= server.featureLimits.backups)
        }
        .navigationTitle("Backups")
        .padding()
        .task {
            await vm.fetchBackups()
        }
        .alert("Name Backup", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Cancel", role: .cancel) {}
            
            Button("Create") {
                Task {
                    await vm.createBackup()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BackupList(PreviewProp.serverAttributes)
    }
    .environment(BackupVM(""))
}
