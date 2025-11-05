import SwiftUI

struct FileSearch: View {
    @Binding private var fieldSearch: String
    
    init(_ fieldSearch: Binding<String>) {
        _fieldSearch = fieldSearch
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .title3(.semibold)
                .secondary()
            
            TextField("Search", text: $fieldSearch)
                .autocorrectionDisabled()
        }
    }
}
