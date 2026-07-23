import SwiftUI

struct ModManagerSearchField: View {
    @Binding var searchQuery: String
    
    let reloadMods: () -> Void
    
    var body: some View {
        TextField("Search", text: $searchQuery)
            .panelSearchField()
            .submitLabel(.search)
            .onSubmit(reloadMods)
    }
}
