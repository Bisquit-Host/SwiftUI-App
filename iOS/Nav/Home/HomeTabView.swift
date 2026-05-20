import SwiftUI

#if os(watchOS)

struct HomeTabView: View {
    var body: some View {
        EmptyView()
    }
}

#else

struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            if (store.accessToken?.isEmpty ?? true) {
                BillingLogin()
                    .withNavDestinations()
            } else {
                Dashboard()
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

#endif

#Preview {
    HomeTabView()
}
