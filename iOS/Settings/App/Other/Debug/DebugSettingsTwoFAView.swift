import SwiftUI

struct DebugSettingsTwoFAView: View {
    @Binding var sheet: DebugTwoFASheet?
    
    var body: some View {
        Section {
            ForEach(DebugTwoFASheet.allCases) { preview in
                Button(preview.title, systemImage: "shield.lefthalf.filled") {
                    sheet = preview
                }
            }
        } header: {
            Text("2FA previews")
        }
    }
}
