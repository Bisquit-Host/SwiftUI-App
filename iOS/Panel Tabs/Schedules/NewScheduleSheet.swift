import SwiftUI
import Calagopus

struct NewScheduleSheet: View {
    @Environment(ScheduleVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = "New schedule"
    @State private var enabled = true
    @State private var onlyWhenOnline = false
    @State private var triggers = [CalagopusScheduleTrigger(type: .cron, schedule: "0 * * * * *")]
    
    private var newSchedule: CalagopusScheduleCreate {
        .init(
            name: name,
            enabled: enabled,
            triggers: triggers,
            condition: onlyWhenOnline ? .onlineScheduleCondition : .object(["type": .string("none")])
        )
    }
    
    var body: some View {
        List {
            Section("Name") {
                TextField("Name", text: $name)
                    .limitInputLength($name, length: 255)
            }
            
            if triggers.isEmpty {
                Section("Triggers") {
                    Button("Add Trigger", systemImage: "plus") {
                        triggers.append(CalagopusScheduleTrigger(type: .cron, schedule: "0 * * * * *"))
                    }
                    .foregroundStyle(.foreground)
                }
            } else {
                ForEach(triggers.indices, id: \.self) { index in
                    Section {
                        ScheduleTriggerRow($triggers[index])
                        
                        Button("Remove Trigger", systemImage: "trash", role: .destructive) {
                            triggers.remove(at: index)
                        }
                        .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Button("Add Trigger", systemImage: "plus") {
                        triggers.append(CalagopusScheduleTrigger(type: .cron, schedule: "0 * * * * *"))
                    }
                    .foregroundStyle(.foreground)
                }
            }
            
            Toggle("Enable", isOn: $enabled)
            Toggle("Only when online", isOn: $onlyWhenOnline)
#if os(tvOS)
            Divider()
#endif
            Section {
                Button("Create Schedule", action: createSchedule)
                    .semibold()
#if os(tvOS)
                    .buttonStyle(.borderedProminent)
#endif
            }
        }
        .navigationTitle("Create Schedule")
        .toolbarTitleDisplayMode(.inline)
        .ornamentDismissButton()
    }
    
    private func createSchedule() {
        Task {
            await vm.createSchedule(newSchedule) {
                dismiss()
            }
        }
    }
}


#Preview {
    NewScheduleSheet()
        .darkSchemePreferred()
        .environment(ScheduleVM(""))
}
