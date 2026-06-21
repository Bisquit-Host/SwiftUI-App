import SwiftUI
import Calagopus

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
        .scrollIndicators(.never)
        .padding()
        .task {
            await vm.fetchBackups()
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Create", role: .confirmy, action: create)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func create() {
        Task {
            await vm.createBackup()
        }
    }
}

#Preview {
    NavigationStack {
        BackupList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
