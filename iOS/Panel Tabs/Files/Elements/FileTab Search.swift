import SwiftUI

struct FileSearch: View {
    @Binding private var fieldSearch: String
    
    init(_ fieldSearch: Binding<String>) {
        _fieldSearch = fieldSearch
    }
    
    #warning("TODO: Implement focus state")
    //    @FocusState private var focusState
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .title3(.semibold)
                .foregroundStyle(.secondary)
            
            TextField("Search", text: $fieldSearch)
                .autocorrectionDisabled()
            //                .focused($focusState)
        }
    }
}
