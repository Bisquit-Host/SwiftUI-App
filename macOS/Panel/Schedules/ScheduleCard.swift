import SwiftUI
import Calagopus

struct ScheduleCard: View {
    private let schedule: CalagopusServerSchedule
    
    init(_ schedule: CalagopusServerSchedule) {
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
