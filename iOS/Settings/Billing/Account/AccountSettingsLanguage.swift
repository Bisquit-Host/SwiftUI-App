import BisquitoNet
import SwiftUI

struct AccountSettingsLanguage: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var selectedLanguage: BillingLanguage = .EN
    @State private var showPicker = false
    
    var body: some View {
        GlassyButton("Language", subtitle: subtitle, icon: "character.cursor.ibeam", tint: .indigo) {
            selectedLanguage = currentLanguage
            showPicker = true
        }
        .sheet($showPicker) {
            NavigationStack {
                Form {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(BillingLanguage.allCases) {
                            Text($0.localizedName)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.inline)
                }
                .navigationTitle("Language")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        DismissButton()
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", systemImage: "checkmark", action: save)
                            .tint(.green)
                            .disabled(selectedLanguage == currentLanguage || vm.isUpdatingLanguage)
                    }
                }
            }
        }
    }
    
    private var currentLanguage: BillingLanguage {
        BillingLanguage(rawValue: user.lang.uppercased()) ?? .EN
    }
    
    private var subtitle: String {
        "\(currentLanguage.localizedName) (\(currentLanguage.rawValue))"
    }
    
    private func save() {
        let language = selectedLanguage
        
        Task {
            guard await vm.updateLanguage(language) else { return }
            
            await dashboardVM.fetchUserInfo()
            showPicker = false
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
