import SwiftUI
import PteroNet

struct BackupCard: View {
    @Environment(BackupVM.self) private var vm
    
    private let backup: BackupAttributes
    
    init(_ backup: BackupAttributes) {
        self.backup = backup
    }
    
    var body: some View {
        HStack {
            Group {
                if backup.completedAt != nil {
                    Image(systemName: "doc.zipper")
                        .title2(.semibold)
                } else {
                    ZStack {
                        ProgressView()
                        
                        Image(systemName: "doc.zipper")
                            .title2(.semibold)
                            .opacity(0)
                    }
                }
            }
            .frame(width: 50)
            
            Text(backup.name)
        }
    }
}

#Preview {
    List {
        BackupCard(sampleJSON(.backupAttributes))
    }
}
