import SwiftUI

struct BillingSettings: View {
    @State private var vm = BillingSettingsVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AccountSettingsSection(user)
                
                if let user {
                    BillingSecuritySettings(user)
                    AuthAppsSection($user)
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.easeInOut, value: user)
            .padding()
        }
        .environment(vm)
        .scrollIndicators(.never)
        .task {
            await dashboardVM.fetchUserInfo()
        }
    }
}

#Preview {
    BillingSettings(.constant(.preview))
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
