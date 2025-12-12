import SwiftUI

#if os(iOS)
struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    @State private var showUpdatePrompt = true
    
    var body: some View {
        @Bindable var nav = nav
        
        TabView(selection: $nav.selectedTab) {
            Tab("Billing", systemImage: "person.crop.circle", value: NavState.RootTab.billing) {
                NavigationStack(path: $nav.billingPath) {
                    Group {
                        if (store.accessToken?.isEmpty ?? true) {
                            BillingLogin()
                        } else {
                            BillingDashboard()
                        }
                    }
                    .withNavDestinations()
                }
            }
            
            Tab("Pterodactyl", systemImage: "externaldrive", value: NavState.RootTab.pterodactyl) {
                NavigationStack(path: $nav.pterodactylPath) {
                    Group {
                        if store.isApiKeyValid {
                            ServerList()
                        } else {
                            StartPage()
                        }
                    }
                    .withNavDestinations()
                }
            }
        }
        .environment(securityTasks)
        .onFirstAppear {
            await securityTasks.startCheck()
        }
        .fullScreenCover($securityTasks.alertUpdate) {
            RequireUpdateView()
        }
    }
}
#else
struct HomeTabView: View {
    var body: some View {
        EmptyView()
    }
}
#endif

#Preview {
    HomeTabView()
}
