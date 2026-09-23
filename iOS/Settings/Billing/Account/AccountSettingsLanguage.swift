import ScrechKit
import BisquitoNet

struct AccountSettingsLanguage: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    var body: some View {
        HStack(spacing: 12) {
            GlassyIcon("character.cursor.ibeam", tint: .indigo)
            
            Text("Language")
                .subheadline(.semibold)
            
            Spacer()
            
            Menu {
                ForEach(BillingLanguage.allCases) { language in
                    AsyncButton(language.localizedName, systemImage: language == currentLanguage ? "checkmark" : "") {
                        await updateLanguage(language)
                    }
                    .disabled(language == currentLanguage)
                }
            } label: {
                HStack(spacing: 6) {
                    Text(subtitle)
                        .lineLimit(1)
                    
                    Image(systemName: "chevron.up.chevron.down")
                }
                .footnote()
                .secondary()
            }
#if !os(visionOS)
            .tint(.primary)
#endif
            .disabled(vm.isUpdatingLanguage)
        }
    }
    
    private var currentLanguage: BillingLanguage {
        BillingLanguage(rawValue: user.lang.uppercased()) ?? .en
    }
    
    private var subtitle: String {
        "\(currentLanguage.localizedName) (\(currentLanguage.rawValue))"
    }
    
    private func updateLanguage(_ language: BillingLanguage) async {
        guard
            language != currentLanguage,
            await vm.updateLanguage(language)
        else {
            return
        }
        
        await dashboardVM.fetchUserInfo()
    }
}

#Preview {
    AccountSettingsLanguage(.preview)
        .padding()
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(DashboardVM())
}
