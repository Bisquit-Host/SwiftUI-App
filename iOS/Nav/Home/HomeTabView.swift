import SwiftUI

#warning("Split")

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

#elseif os(visionOS)

struct HomeTabView: View {
    @State private var dashboardVM = DashboardVM()
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    @State private var sheetTopup = false
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var dashboardVM = dashboardVM
        
        NavigationStack(path: $nav.path) {
            Group {
                if store.accessToken?.isEmpty ?? true {
                    LoginView()
                } else {
                    Dashboard()
                }
            }
            .withNavDestinations()
            .toolbar {
                if showsBillingToolbar, let user = dashboardVM.user {
                    ToolbarItem(placement: .topBarLeading) {
                        BillingDashboardBalance(user) {
                            sheetTopup = true
                        }
                    }
                }
                
                if showsBillingToolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Settings", systemImage: "gear") {
                            sheetSettings = true
                        }
                    }
                }
            }
        }
        .environment(dashboardVM)
        .sheet($sheetSettings) {
            NavigationStack {
                SettingsView($dashboardVM.user)
                    .environment(dashboardVM)
            }
        }
        .sheet($sheetTopup) {
            NavigationStack {
                if let user = dashboardVM.user {
                    SheetTopup(user)
                        .environment(dashboardVM)
                } else {
                    ProgressView()
                        .navigationTitle("Finance stuff")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .animation(.default, value: dashboardVM.user)
    }
    
    private var showsBillingToolbar: Bool {
        !(store.accessToken?.isEmpty ?? true)
    }
}

#else

struct HomeTabView: View {
    var body: some View {
        Dashboard()
    }
}

#endif

#Preview {
    NavigationStack {
        HomeTabView()
    }
    .environmentObject(ValueStore())
}
