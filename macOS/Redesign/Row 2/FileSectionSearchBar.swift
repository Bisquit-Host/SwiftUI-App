import SwiftUI

struct FileSectionSearchBar: View {
    @State private var search = ""
    
    var body: some View {
        HStack {
            TextField("Search here", text: $search)
                .textFieldStyle(.roundedBorder)
            
            Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    FileSectionSearchBar()
}
