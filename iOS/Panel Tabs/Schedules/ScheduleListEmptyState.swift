import SwiftUI

struct ScheduleListEmptyState: View {
    var body: some View {
        ContentUnavailableView(
            "No schedules",
            systemImage: "calendar.badge.plus",
            description: Text("Create a schedule to automate server tasks")
        )
    }
}

#Preview {
    ScheduleListEmptyState()
        .darkSchemePreferred()
}
