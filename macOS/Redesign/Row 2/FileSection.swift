import SwiftUI

struct FileSection: View {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        Card("Files") {
            VStack {
                FileSectionSearchBar()
                
                HStack(spacing: 16) {
                    Group {
                        HeaderCell("Name")
                        HeaderCell("Size")
                        HeaderCell("Date")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 6)
                
                FileListRedesign(id)
            }
        }
        .frame(height: 500)
        .frame(maxWidth: .infinity)
    }
}
