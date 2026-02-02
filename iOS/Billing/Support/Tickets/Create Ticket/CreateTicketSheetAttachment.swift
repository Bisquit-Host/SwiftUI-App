import SwiftUI

struct CreateTicketSheetAttachment: View {
    private let file: PendingAttachment
    private let deleteAll: () -> Void
    
    init(_ file: PendingAttachment, deleteAll: @escaping () -> Void) {
        self.file = file
        self.deleteAll = deleteAll
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(file.filename)
                    .lineLimit(1)
                
                Text(file.readableSize)
                    .caption()
                    .secondary()
            }
            
            Spacer()
            
            Button(role: .destructive) {
                deleteAll()
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

//#Preview {
//    CreateTicketSheetAttachment()
//}
