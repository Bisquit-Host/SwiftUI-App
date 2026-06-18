import SwiftUI

#if os(watchOS)

struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            if store.isApiKeyValid {
                ServerList()
            } else {
                StartPage()
            }
        }
        .withNavDestinations()
        .environment(securityTasks)
    }
}

#else

struct HomeTabView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if (store.accessToken?.isEmpty ?? true) {
            LoginView()
        } else {
            Dashboard()
        }
    }
}

#endif

#Preview {
    NavigationStack {
        HomeTabView()
    }
    .environmentObject(ValueStore())
}
