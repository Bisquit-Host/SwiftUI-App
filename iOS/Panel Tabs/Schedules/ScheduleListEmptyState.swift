import SwiftUI

struct ScheduleListEmptyState: View {
    var body: some View {
        ContentUnavailableView(
            "This server currently has no schedules",
            systemImage: "calendar.badge.plus",
            description: Text("Click the button in the top right corner to create a schedule")
        )
    }
}

#Preview {
    ScheduleListEmptyState()
        .darkSchemePreferred()
}
