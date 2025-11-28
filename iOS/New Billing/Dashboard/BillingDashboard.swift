import ScrechKit

struct BillingDashboard: View {
    @State private var vm = BillingDashboardVM()
    
    @State private var sheetSettings = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    NavigationLink {
                        SupportTicketsList()
                    } label: {
                        Label("Support", systemImage: "lifepreserver.fill")
                            .headline()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarBackButtonHidden()
        .refreshableTask {
            await vm.fetchUserInfo()
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
                    BillingDashboardBalance(balance: Double(user.balance), currency: user.currency)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("gear") {
                    sheetSettings = true
                }
            }
        }
        .animation(.default, value: vm.user)
    }
}

#Preview {
    NavigationStack {
        BillingDashboard()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
