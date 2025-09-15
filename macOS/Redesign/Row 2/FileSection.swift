import SwiftUI

struct FileSection: View {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        Card("Files") {
            VStack(spacing: 32) {
                FileSectionSearchBar()
                
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                    GridRow {
                        HeaderCell("Name")
                        HeaderCell("Size")
                        HeaderCell("Date")
                    }
                    
                    FileListRedesign(id)
                }
            }
        }
        .frame(height: 500)
        .frame(maxWidth: .infinity)
    }
}
