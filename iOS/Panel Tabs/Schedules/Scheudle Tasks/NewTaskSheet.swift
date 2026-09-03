import SwiftUI
import Calagopus

struct NewTaskSheet: View {
    @Environment(ScheduleVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var state = NewTaskState()
    
    private let scheudleID: String
    
    init(_ scheudleID: String) {
        self.scheudleID = scheudleID
    }
    
    var body: some View {
        List {
            Section("Action") {
                Picker("Action", selection: $state.action) {
                    ForEach(CalagopusScheduleTaskAction.panelCases) {
                        Label($0.taskLabel, systemImage: $0.taskIcon)
                            .tag($0)
                    }
                }
            }
            
            NewTaskFields(
                state: $state,
                backupGroups: vm.backupGroups
            )
            Section {
                Button("Create Task") {
                    Task {
                        let newTask = state.makeTask(order: vm.nextStepOrder(for: scheudleID))
                        await vm.createScheduleTask(scheudleID, newTask: newTask) {
                            dismiss()
                        }
                    }
                }
                .disabled(!state.hasValidActionInput)
            }
        }
        .task {
            await vm.fetchBackupGroupsIfNeeded()
        }
    }
}

#Preview {
    NewTaskSheet("")
        .darkSchemePreferred()
        .environment(ScheduleVM(""))
}
