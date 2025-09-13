import SwiftUI

struct FileSection: View {
    @State private var search = ""
    
    var body: some View {
        Card(title: "Files") {
            VStack(spacing: 32) {
                HStack {
                    TextField("Search here", text: $search)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                        
                    }
                    .buttonStyle(.bordered)
                }
                
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
