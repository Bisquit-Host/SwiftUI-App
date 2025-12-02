import ScrechKit
import SwiftUI

struct BillingDashboard: View {
    @State private var vm = BillingDashboardVM()
    
    @State private var sheetSettings = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BillingDashboardHostingLinks()
                    
                    NavigationLink {
                        SupportTicketsList()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "lifepreserver")
                                .largeTitle()
                                .foregroundStyle(.red)
                            
                            VStack(alignment: .leading) {
                                Text("Support")
                                
                                Text("Tickets & wiki")
                                    .footnote()
                                    .secondary()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                    }
                    .foregroundStyle(.foreground)
                }
                .padding()
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarBackButtonHidden()
        .refreshableTask {
            await vm.fetchUserInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await vm.fetchUserInfo()
            }
        }
        .sheet($sheetSettings) {
            NavigationStack {
                BillingSettings($vm.user)
                    .environment(vm)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let user = vm.user {
                    BillingDashboardBalance(user)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("gear") {
                    sheetSettings = true
                }
            }
        }
        .animation(.default, value: vm.user)
        .environment(vm)
    }
}

#Preview {
    NavigationStack {
        BillingDashboard()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
