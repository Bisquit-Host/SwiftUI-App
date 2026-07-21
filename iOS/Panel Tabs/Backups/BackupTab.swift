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

            if !vm.backupGroups.isEmpty {
                Section("New backups") {
                    Picker("Backup group", selection: $vm.selectedBackupGroupID) {
                        Text("No group")
                            .tag(nil as String?)

                        ForEach(vm.backupGroups) {
                            Text($0.name)
                                .tag($0.uuid as String?)
                        }
                    }
                }
            }
        }
        .animation(.default, value: vm.backups.count)
        .scrollIndicators(.never)
        .overlay {
            if vm.isLoadingBackups && vm.backups.isEmpty {
                ProgressView()
            } else if vm.hasFinishedLoadingBackups && vm.backups.isEmpty {
                BackupListEmptyState()
            }
        }
#if !os(tvOS)
        .frame(maxWidth: 500)
#endif
        .refreshableTask {
            await vm.fetchBackups()
        }
        .task {
            await vm.fetchBackupGroupsIfNeeded()
        }
#if !os(tvOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
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
