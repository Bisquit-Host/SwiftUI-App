import SwiftUI

struct FileSection: View {
    @StateObject private var vm: FileTabVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        Card("Files") {
            VStack {
                FileSectionSearch()
                
                HStack(spacing: 0) {
                    Group {
                        HeaderCell("Name")
                        HeaderCell("Size")
                        HeaderCell("Created")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 6)
                
                FileListRedesign(id)
            }
        }
        .environmentObject(vm)
        .frame(height: 500)
        .frame(maxWidth: .infinity)
    }
}
