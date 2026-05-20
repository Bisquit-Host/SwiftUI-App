import SwiftUI
import SwiftData

struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            if store.isApiKeyValid {
                ServerList()
                    .withNavDestinations()
            } else {
                StartPage()
                    .withNavDestinations()
            }
        }
        .environment(securityTasks)
        .onFirstAppear {
            await securityTasks.startCheck()
        }
        .fullScreenCover($securityTasks.alertUpdate) {
            UpdateSheet()
        }
    }
}
