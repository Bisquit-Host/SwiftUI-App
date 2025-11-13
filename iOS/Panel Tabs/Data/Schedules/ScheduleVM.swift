import SwiftUI
import PteroNet

@Observable
final class ScheduleVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var schedules: [ScheduleAttributes] = []
    var sheetCreateTask = false
    var sheetCreate = false
    
    func fetchSchedules() async {
        do {
            let schedules: ScheduleListResponse? = try await dataListAPI(
                id,
                endpoint: .schedules
            )
            
            if let schedules = schedules?.data.map(\.attributes) {
                self.schedules = schedules
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createSchedule(
        _ newSchedule: NewSchedule,
        onSuccess: @escaping () -> Void
    ) async {
        do {
            let model = try await scheduleCreateAPI(id, newSchedule: newSchedule)
            
            schedules.append(model)
        } catch {
            await MainActor.run {
                SystemAlert.error(error)
            }
        }
    }
    
    func executeSchedule(_ scheduleId: Int) async {
        do {
            try await scheduleExecuteAPI(id, scheduleId: scheduleId)
        } catch {
            await MainActor.run {
                SystemAlert.error(error)
            }
        }
    }
    
    func deleteSchedules(_ offsets: IndexSet) {
        for index in offsets {
            let id = schedules[index].id.description
            
            Task {
                await deleteSchedule(id)
            }
        }
    }
    
    func deleteSchedule(_ uuid: String) async {
        do {
            try await dataDeleteAPI(id, itemId: uuid, endpoint: .schedules)
            await fetchSchedules()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createScheduleTask(
        _ scheduleId: Int,
        newTask: NewScheduleTask,
        onSuccess: @escaping () -> Void
    ) async {
        do {
            let model = try await scheduleTaskCreateAPI(id, scheduleId: scheduleId, newTask: newTask)
            
            withAnimation {
                if let index = self.schedules.firstIndex(where: { $0.id == scheduleId }) {
                    self.schedules[index].relationships.tasks.data.append(model)
                }
            }
            
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteScheduleTask(_ scheduleId: Int, taskId: Int) async {
        do {
            try await scheduleTaskDeleteAPI(id, scheduleId: scheduleId, taskId: taskId)
            
            if let scheduleIndex = self.schedules.firstIndex(where: {
                $0.id == scheduleId
            }) {
                if let taskIndex = self.schedules[scheduleIndex].relationships.tasks.data.firstIndex(where: { $0.attributes.id == taskId }) {
                    self.schedules[scheduleIndex].relationships.tasks.data.remove(at: taskIndex)
                }
            }
        } catch {
            networkCallError(#function, error)
        }
    }
}
