import SwiftUI
import PteroNet

struct NewTaskSheet: View {
    @Environment(ScheduleVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    private let scheudleId: Int
    
    init(_ scheudleId: Int) {
        self.scheudleId = scheudleId
    }
    
    @State private var action: ScheduleTaskAction = .backup
    @State private var payload = ""
    @State private var timeOffset = "0"
    @State private var continueOnFailure = false
    
    private var newTask: NewScheduleTask {
        .init(
            action: action.rawValue,
            payload: payload,
            timeOffset: Int(timeOffset) ?? 0,
            continueOnFailure: continueOnFailure
        )
    }
    
    var body: some View {
        List {
            Section("Action") {
                Picker("Action", selection: $action) {
                    Text("Backup")
                        .tag(ScheduleTaskAction.backup)
                    
                    Text("Power")
                        .tag(ScheduleTaskAction.power)
                    
                    Text("Command")
                        .tag(ScheduleTaskAction.command)
                }
            }
            
            Section("Payload") {
                TextField("Payload", text: $payload)
            }
            
            Section("Time offset (sec)") {
                TextField("", text: $timeOffset)
                    .keyboardType(.numberPad)
            }
            
            Toggle("Continue on failure", isOn: $continueOnFailure)
                .foregroundStyle(continueOnFailure ? .green : .red)
            
#if os(tvOS)
            Divider()
#endif
            Section {
                Button("Create Task") {
                    vm.createScheduleTask(scheudleId, newTask: newTask)
                    dismiss()
                }
#if os(tvOS)
                .buttonStyle(.borderedProminent)
#endif
            }
        }
    }
}

//#Preview {
//    NewTaskSheet(0)
//}
