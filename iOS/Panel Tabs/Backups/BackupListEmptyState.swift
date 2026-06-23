import SwiftUI

struct BackupListEmptyState: View {
    var body: some View {
        ContentUnavailableView(
            "No backups yet",
            systemImage: "doc.zipper",
            description: Text("Use the button in the top right corner to create one")
        )
    }
}

#Preview {
    List {
        BackupListEmptyState()
    }
    .darkSchemePreferred()
}
