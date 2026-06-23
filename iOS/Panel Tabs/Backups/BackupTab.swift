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
            BackupList(server)
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .animation(.default, value: vm.backups.count)
        .scrollIndicators(.never)
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            await vm.fetchBackups()
        }
#if !os(tvOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .toolbar {
            Button("Create backup", image: .customArchiveboxBadgePlus) {
                vm.alertCreateBackup = true
            }
            .labelStyle(.iconOnly)
            .disabled(vm.backups.count >= server.featureLimits.backups)
        }
        .alert("Backup name", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Create", role: .confirm, action: createBackup)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func createBackup() {
        Task {
            await vm.createBackup()
        }
    }
}

#Preview {
    BackupTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
