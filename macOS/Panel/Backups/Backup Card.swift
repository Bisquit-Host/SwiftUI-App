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
            Text(backup.name)
            
            Text(backup.createdAt)
                .footnote()
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            if backup.isLocked {
                Image(systemName: "lock")
            }
        }
    }
}

#Preview {
    BackupCard(sampleJSON(.backupAttributes))
        .environment(BackupVM(""))
}
