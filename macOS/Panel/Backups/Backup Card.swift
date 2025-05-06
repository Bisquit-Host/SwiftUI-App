import SwiftUI
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(backup.name)
                
                if backup.isLocked {
                    Image(systemName: "lock")
                }
            }
            
            Text(backup.createdAt)
                .footnote()
                .secondary()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
        .contextMenu {
            Button {
                vm.lockBackup(backup.uuid)
            } label: {
                Label(backup.isLocked ? "Unlock" : "Lock", systemImage: backup.isLocked ? "lock.open" : "lock")
            }
            
            Button(role: .destructive) {
                vm.deleteBackup(backup.uuid)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(backup.isLocked)
        }
    }
}

#Preview {
    BackupCard(sampleJSON(.backupAttributes))
        .environment(BackupVM(""))
}
