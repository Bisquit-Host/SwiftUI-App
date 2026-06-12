import ScrechKit
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        NavigationLink {
            BackupDetails(backup)
                .environment(vm)
        } label: {
            BackupCardContent(backup)
        }
    }
}

#Preview {
    List {
        BackupCard(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
