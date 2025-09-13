import SwiftUI

struct FileCardRedesign: View {
    private let file: TaskItem
    
    init(_ file: TaskItem) {
        self.file = file
    }
    
    var body: some View {
        GridRow {
            HStack {
                Circle()
                    .frame(width: 10)
                
                Text(file.name)
            }
            
            ProjectPill(project: file.project)
            
            Text(file.dateCreated.formatted(date: .abbreviated, time: .omitted))
                .secondary()
        }
        .padding(.vertical, 6)
        
        Divider()
    }
}

//#Preview {
//    FileCardRedesign()
//}
