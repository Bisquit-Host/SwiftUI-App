import ScrechKit

struct BillingDashboard: View {
    @State private var vm = BillingDashboardVM()
    
    @State private var sheetSettings = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Text("Dashboard")
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
    BillingDashboard()
        .darkSchemePreferred()
}
