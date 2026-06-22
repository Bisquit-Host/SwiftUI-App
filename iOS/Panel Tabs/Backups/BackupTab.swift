import SwiftUI
import Calagopus

struct BackupTab: View {
    @Environment(BackupVM.self) private var backupVM
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        @Bindable var backupVM = backupVM
        
        List {
            BackupList(server)
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollIndicators(.never)
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            await backupVM.fetchBackups()
        }
#if !os(tvOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .alert("Backup name", isPresented: $backupVM.alertCreateBackup) {
            TextField("Backup at \(backupVM.dateAndTime)", text: $backupVM.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($backupVM.textCreateBackup, length: 191)
            
            Button("Create", role: .confirm, action: createBackup)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func createBackup() {
        Task {
            await backupVM.createBackup()
        }
    }
}

#Preview {
    BackupTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
}
