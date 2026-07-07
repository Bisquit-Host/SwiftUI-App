import BisquitoNet
import SwiftUI

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
                    Button(language.localizedName, systemImage: language == currentLanguage ? "checkmark" : "") {
                        updateLanguage(language)
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
            .tint(.primary)
            .disabled(vm.isUpdatingLanguage)
        }
    }
    
    private var currentLanguage: BillingLanguage {
        BillingLanguage(rawValue: user.lang.uppercased()) ?? .EN
    }
    
    private var subtitle: String {
        "\(currentLanguage.localizedName) (\(currentLanguage.rawValue))"
    }
    
    private func updateLanguage(_ language: BillingLanguage) {
        guard language != currentLanguage else { return }
        
        Task {
            guard await vm.updateLanguage(language) else { return }
            
            await dashboardVM.fetchUserInfo()
        }
    }
}

#Preview {
    AccountSettingsLanguage(.preview)
        .padding()
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(DashboardVM())
}
