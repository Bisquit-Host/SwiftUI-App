import SwiftUI
import PteroNet

struct NewScheduleSheet: View {
    @Environment(ScheduleVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var newSchedule = NewSchedule(
        name: "New schedule",
        isActive: true,
        onlyWhenOnline: true,
        minute: "*",
        hour: "*",
        dayOfMonth: "*",
        month: "*",
        dayOfWeek: "*"
    )
    
    var body: some View {
        List {
            Section("Name") {
                TextField("Name", text: $newSchedule.name)
            }
            
            Section("Minute") {
                TextField("Minute", text: $newSchedule.minute)
            }
            
            Section("Hour") {
                TextField("Hour", text: $newSchedule.hour)
            }
            
            Section("Day of month") {
                TextField("Day of month", text: $newSchedule.dayOfMonth)
            }
            
            Section("Month") {
                TextField("Month", text: $newSchedule.month)
            }
            
            Section("Day of week") {
                TextField("Day of week", text: $newSchedule.dayOfWeek)
            }
            
            Toggle("Enable Schedule", isOn: $newSchedule.isActive)
                .foregroundStyle(newSchedule.isActive ? .green : .red)
            
            Toggle("Only when online", isOn: $newSchedule.onlyWhenOnline)
                .foregroundStyle(newSchedule.onlyWhenOnline ? .green : .red)
#if os(tvOS)
            Divider()
#endif
            Section {
#if os(visionOS)
                Button("Dismiss") {
                    dismiss()
                }
#endif
                Button("Create Schedule") {
                    vm.createSchedule(newSchedule)
                    dismiss()
                }
#if os(tvOS)
                .buttonStyle(.borderedProminent)
#endif
            }
        }
    }
}

#Preview {
    NewScheduleSheet()
}
