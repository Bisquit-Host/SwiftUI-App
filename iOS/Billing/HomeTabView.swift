import SwiftUI

struct HomeTabView: View {
    @State private var securityTasks = SecurityTasks()
    @EnvironmentObject private var store: ValueStore
    
    @State private var showUpdatePrompt = true
    
    var body: some View {
        TabView {
#if os(iOS)
            Tab("Billing", systemImage: "person.crop.circle") {
                if (store.accessToken?.isEmpty ?? true) {
                    BillingLogin()
                        .withNavDestinations()
                } else {
                    BillingDashboard()
                        .withNavDestinations()
                }
            }
#endif
            Tab("Pterodactyl", systemImage: "externaldrive") {
                if store.isApiKeyValid {
                    ServerList()
                        .withNavDestinations()
                } else {
                    StartPage()
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

#Preview {
    HomeTabView()
}
