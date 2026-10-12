import ScrechKit
import Calagopus

struct BackupDetailsHeader: View {
    @Environment(BackupVM.self) private var vm

    private let backup: CalagopusServerBackup

    init(_ backup: CalagopusServerBackup) {
        self.backup = backup
    }

    var body: some View {
        Section {
            VStack {
                Image(systemName: vm.symbol(for: backup))
                    .largeTitle(.semibold)
                    .foregroundStyle(.tint)

                Text(backup.name)
                    .title3(.semibold)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)

                BackupDetailsStatus(backup)
                    .footnote()
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        BackupDetailsHeader(PreviewProp.backupAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
