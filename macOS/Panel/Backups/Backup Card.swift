import SwiftUI
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        VStack {
            Text(backup.name)
            Text(backup.createdAt)
        }
    }
}

#Preview {
    BackupCard(
        sampleJSON(.backupAttributes)
    )
}
