import SwiftUI

struct FileSection: View {
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
                    
                    FileListRedesign()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
