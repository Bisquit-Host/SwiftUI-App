import SwiftUI

struct FileSectionSearch: View {
    @EnvironmentObject private var vm: FileTabVM
    
    var body: some View {
        HStack {
            TextField("Search here", text: $vm.searchField)
                .textFieldStyle(.roundedBorder)
            
            //            Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
            //
            //            }
            //            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    FileSectionSearch()
        .darkSchemePreferred()
        .environmentObject(FileTabVM(""))
}
