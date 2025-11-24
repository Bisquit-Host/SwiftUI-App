import ScrechKit

struct BillingDashboard: View {
    @State private var sheetSettings = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Text("Dashboard")
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarBackButtonHidden()
        .sheet($sheetSettings) {
            NavigationStack {
                BillingSettings()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // BillingDashboardBalance(balance: 0, currency: "EUR")
                BillingDashboardBalance(balance: 200, currency: "EUR")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("gear") {
                    sheetSettings = true
                }
            }
        }
    }
}

#Preview {
    BillingDashboard()
        .darkSchemePreferred()
}
