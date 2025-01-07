import SwiftUI
import PteroNet

struct NewScheduleSheet: View {
    @Environment(ScheduleVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = "New Schedule"
    @State private var isActive = true
    @State private var onlyWhenOnline = true
    @State private var minute = "*"
    @State private var hour = "*"
    @State private var dayOfMonth = "*"
    @State private var month = "*"
    @State private var dayOfWeek = "*"
    
    private var newSchedule: NewSchedule {
        NewSchedule(
            name: name,
            isActive: isActive,
            onlyWhenOnline: onlyWhenOnline,
            minute: minute,
            hour: hour,
            dayOfMonth: dayOfMonth,
            month: month,
            dayOfWeek: dayOfWeek
        )
    }
    
    var body: some View {
        List {
            Section("Name") {
                TextField("Name", text: $name)
            }
            
            Section("Minute") {
                TextField("Minute", text: $minute)
            }
            
            Section("Hour") {
                TextField("Hour", text: $hour)
            }
            
            Section("Day of month") {
                TextField("Day of month", text: $dayOfMonth)
            }
            
            Section("Month") {
                TextField("Month", text: $month)
            }
            
            Section("Day of week") {
                TextField("Day of week", text: $dayOfWeek)
            }
            
            Toggle("Enable Schedule", isOn: $isActive)
                .foregroundStyle(isActive ? .green : .red)
            
            Toggle("Only when online", isOn: $onlyWhenOnline)
                .foregroundStyle(onlyWhenOnline ? .green : .red)
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
