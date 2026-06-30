import SwiftUI
import Calagopus

@Observable
final class ScheduleVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var schedules: [CalagopusServerSchedule] = []
    private(set) var stepsByScheduleID: [String: [CalagopusServerScheduleStep]] = [:]
    var sheetCreateTask = false
    var sheetCreate = false
    
    func fetchSchedules() async {
        do {
            schedules = try await CalagopusNet.client().schedules(server: id).data
            stepsByScheduleID = [:]
            
            for schedule in schedules {
                stepsByScheduleID[schedule.id] = try await CalagopusNet.client().scheduleSteps(server: id, schedule: schedule.id)
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createSchedule(_ newSchedule: CalagopusScheduleCreate, onSuccess: @escaping () -> Void) async {
        do {
            let model = try await CalagopusNet.client().createSchedule(server: id, schedule: newSchedule)
            
            schedules.append(model)
            stepsByScheduleID[model.id] = []
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func executeSchedule(_ scheduleId: String) async {
        do {
            try await CalagopusNet.client().triggerSchedule(server: id, schedule: scheduleId)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteSchedules(_ offsets: IndexSet) {
        for index in offsets {
            let id = schedules[index].id
            
            Task {
                await deleteSchedule(id)
            }
        }
    }
    
    func deleteSchedule(_ uuid: String) async {
        do {
            try await CalagopusNet.client().deleteSchedule(server: id, schedule: uuid)
            await fetchSchedules()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createScheduleTask(_ scheduleId: String, newTask: CalagopusScheduleTaskCreate, onSuccess: @escaping () -> Void) async {
        do {
            let model = try await CalagopusNet.client().createScheduleStep(server: id, schedule: scheduleId, task: newTask)
            
            withAnimation {
                self.stepsByScheduleID[scheduleId, default: []].append(model)
            }
            
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteScheduleTask(_ scheduleId: String, taskId: String) async {
        do {
            try await CalagopusNet.client().deleteScheduleStep(server: id, schedule: scheduleId, step: taskId)
            
            if let taskIndex = self.stepsByScheduleID[scheduleId]?.firstIndex(where: { $0.id == taskId }) {
                self.stepsByScheduleID[scheduleId]?.remove(at: taskIndex)
            }
        } catch {
            networkCallError(#function, error)
        }
    }
}
