import SwiftUI

struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @Environment(NavState.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            ServerList()
        }
        .withNavDestinations()
        .environment(securityTasks)
    }
}
