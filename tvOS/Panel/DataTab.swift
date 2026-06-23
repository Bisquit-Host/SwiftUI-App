import SwiftUI
import Calagopus

struct DataTab: View {
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        NavigationStack {
            List {
                BackupList(server)
                DatabaseList(server.featureLimits.databases)
                ScheduleList()
            }
            .navigationTitle("Data")
        }
    }
}

#Preview {
    DataTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
}
