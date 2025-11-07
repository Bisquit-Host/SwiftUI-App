import SwiftUI
import PteroNet

struct ScheduleCard: View {
    private let schedule: ScheduleAttributes
    
    init(_ schedule: ScheduleAttributes) {
        self.schedule = schedule
    }
    
    var body: some View {
        Text(schedule.name)
    }
}

//#Preview {
//    ScheduleCard(PreviewProp.scheduleAttributes)
//        .darkSchemePreferred()
//        .environment(ScheduleVM(""))
//}
