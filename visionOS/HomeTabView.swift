import SwiftUI

struct HomeTabView: View {
    @State private var dashboardVM = DashboardVM()
    @State private var securityTasks = SecurityTasks()
    @State private var selectedTab = VisionHomeTab.billing
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    @State private var sheetTopup = false
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var dashboardVM = dashboardVM
        
        Group {
            if store.accessToken?.isEmpty ?? true {
                NavigationStack {
                    LoginView()
                }
            } else {
                TabView(selection: $selectedTab) {
                    Tab("Billing", systemImage: "creditcard", value: .billing) {
                        NavigationStack {
                            Dashboard()
                                .toolbar {
                                    if let user = dashboardVM.user {
                                        ToolbarItem(placement: .topBarLeading) {
                                            BillingDashboardBalance(user) {
                                                sheetTopup = true
                                            }
                                        }
                                    }

                                    ToolbarItem(placement: .topBarTrailing) {
                                        Button("Settings", systemImage: "gear") {
                                            sheetSettings = true
                                        }
                                    }
                                }
                        }
                    }

                    Tab("Calagopus", systemImage: "externaldrive", value: .calagopus) {
                        NavigationStack(path: $nav.path) {
                            ServerListParent(showsSettingsToolbarItem: false)
                                .withNavDestinations()
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
        .environment(securityTasks)
        .onFirstAppear {
            await securityTasks.startCheck()
        }
        .fullScreenCover($securityTasks.alertUpdate) {
            UpdateSheet()
        }
    }
}

#Preview {
    HomeTabView()
        .environment(NavState())
        .environmentObject(ValueStore())
}
