import SwiftUI

struct DebugSettingsTwoFAView: View {
    @Binding var sheet: DebugTwoFASheet?
    @Binding var disableTwoFAAlert: Bool

    var body: some View {
        Section {
            ForEach(DebugTwoFASheet.allCases) { preview in
                Button(preview.title, systemImage: "shield.lefthalf.filled") {
                    if preview == .calagopusDisable {
                        disableTwoFAAlert = true
                    } else {
                        sheet = preview
                    }
                }
            }
        } header: {
            Text("2FA previews")
        } footer: {
            Text("Mock data only — account security settings are not changed")
        }
    }
}
