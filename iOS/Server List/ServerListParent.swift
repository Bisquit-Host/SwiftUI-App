import SwiftUI

struct ServerListParent: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.isApiKeyValid {
            ServerList()
        } else {
            StartPage()
        }
    }
}
