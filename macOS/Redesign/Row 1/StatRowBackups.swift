import SwiftUI
import PteroNet

struct StatRowBackups: View {
    @State private var vm: BackupVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = BackupVM(server.id)
    }
    
    @State private var sheetBackups = false
    
    var body: some View {
        Button {
            sheetBackups = true
        } label: {
            StatTile("Backups", value: vm.backups.count, icon: "archivebox")
        }
        .task {
            await vm.fetchBackups()
        }
        .sheet($sheetBackups) {
            BackupList(server)
                .environment(vm)
        }
    }
}

#Preview {
    StatRowBackups(PreviewProp.serverAttributes)
}
